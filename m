From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 20/20] net: sched: remove unused is_classid_clsact_ingress/egress helpers
Date: Tue, 17 Oct 2017 22:06:15 +0200
Message-ID: <20171017200615.4530-21-jiri@resnulli.us>
References: <20171017200615.4530-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:48920 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764075AbdJQUGe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:34 -0400
Received: by mail-wm0-f66.google.com with SMTP id i124so6018127wmf.3
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:34 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
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
