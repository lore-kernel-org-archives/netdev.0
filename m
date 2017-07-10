From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 2/4] net: sched: intruduce qdisc_net helper
Date: Mon, 10 Jul 2017 20:51:08 +0200
Message-ID: <20170710185110.3180-3-jiri@resnulli.us>
References: <20170710185110.3180-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, stephen@networkplumber.org, jbenc@redhat.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        john.fastabend@gmail.com, alexander.h.duyck@intel.com,
        daniel@iogearbox.net, ogerlitz@mellanox.com, mrv@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32823 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754647AbdGJSvR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 14:51:17 -0400
Received: by mail-wr0-f196.google.com with SMTP id x23so26880659wrb.0
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 11:51:17 -0700 (PDT)
In-Reply-To: <20170710185110.3180-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

There is going to be need to be able to obtain net structure for
a qdisc. So introduce helper to do it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_sched.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 2579c20..da85ad0 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -4,7 +4,9 @@
 #include <linux/jiffies.h>
 #include <linux/ktime.h>
 #include <linux/if_vlan.h>
+#include <linux/netdevice.h>
 #include <net/sch_generic.h>
+#include <net/net_namespace.h>
 
 #define DEFAULT_TX_QUEUE_LEN	1000
 
@@ -132,4 +134,9 @@ static inline unsigned int psched_mtu(const struct net_device *dev)
 	return dev->mtu + dev->hard_header_len;
 }
 
+static inline struct net *qdisc_net(struct Qdisc *q)
+{
+	return dev_net(q->dev_queue->dev);
+}
+
 #endif
-- 
2.9.3
