From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 31/34] net: sched: remove unused is_classid_clsact_ingress/egress helpers
Date: Thu, 12 Oct 2017 19:18:20 +0200
Message-ID: <20171012171823.1431-32-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:47989 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755002AbdJLRSx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:53 -0400
Received: by mail-wm0-f68.google.com with SMTP id t69so15072581wmt.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:53 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

These helpers are no longer in use by drivers, so remove them.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_sched.h | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 2d234af..b8ecafc 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -135,19 +135,6 @@ static inline unsigned int psched_mtu(const struct net_device *dev)
 	return dev->mtu + dev->hard_header_len;
 }
 
-static inline bool is_classid_clsact_ingress(u32 classid)
-{
-	/* This also returns true for ingress qdisc */
-	return TC_H_MAJ(classid) == TC_H_MAJ(TC_H_CLSACT) &&
-	       TC_H_MIN(classid) != TC_H_MIN(TC_H_MIN_EGRESS);
-}
-
-static inline bool is_classid_clsact_egress(u32 classid)
-{
-	return TC_H_MAJ(classid) == TC_H_MAJ(TC_H_CLSACT) &&
-	       TC_H_MIN(classid) == TC_H_MIN(TC_H_MIN_EGRESS);
-}
-
 static inline struct net *qdisc_net(struct Qdisc *q)
 {
 	return dev_net(q->dev_queue->dev);
-- 
2.9.5
