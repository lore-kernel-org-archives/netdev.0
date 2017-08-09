From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] net: sched: Add helpers to identify classids
Date: Wed,  9 Aug 2017 14:30:31 +0200
Message-ID: <20170809123035.7663-2-jiri@resnulli.us>
References: <20170809123035.7663-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, oss-drivers@netronome.com,
        ganeshgr@chelsio.com, jeffrey.t.kirsher@intel.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36647 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752741AbdHIMak (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:30:40 -0400
Received: by mail-wr0-f194.google.com with SMTP id y67so4390256wrb.3
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:30:40 -0700 (PDT)
In-Reply-To: <20170809123035.7663-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Offloading drivers need to understand what qdisc class a filter is added
to. Currently they only need to identify ingress, clsact->ingress and
clsact->egress. So provide these helpers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_sched.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 2579c20..259bc19 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -5,6 +5,7 @@
 #include <linux/ktime.h>
 #include <linux/if_vlan.h>
 #include <net/sch_generic.h>
+#include <uapi/linux/pkt_sched.h>
 
 #define DEFAULT_TX_QUEUE_LEN	1000
 
@@ -132,4 +133,17 @@ static inline unsigned int psched_mtu(const struct net_device *dev)
 	return dev->mtu + dev->hard_header_len;
 }
 
+static inline bool is_classid_clsact_ingress(u32 classid)
+{
+	/* This also returns true for ingress qdisc */
+	return TC_H_MAJ(classid) == TC_H_MAJ(TC_H_CLSACT) &&
+	       TC_H_MIN(classid) != TC_H_MIN(TC_H_MIN_EGRESS);
+}
+
+static inline bool is_classid_clsact_egress(u32 classid)
+{
+	return TC_H_MAJ(classid) == TC_H_MAJ(TC_H_CLSACT) &&
+	       TC_H_MIN(classid) == TC_H_MIN(TC_H_MIN_EGRESS);
+}
+
 #endif
-- 
2.9.3
