From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] net: sched: remove handle propagation down to the drivers
Date: Wed,  9 Aug 2017 14:30:34 +0200
Message-ID: <20170809123035.7663-5-jiri@resnulli.us>
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
Received: from mail-wr0-f194.google.com ([209.85.128.194]:37512 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752091AbdHIMap (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:30:45 -0400
Received: by mail-wr0-f194.google.com with SMTP id f38so3358758wrf.4
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:30:45 -0700 (PDT)
In-Reply-To: <20170809123035.7663-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

There is no longer need to use handle in drivers, so remove it from
tc_cls_common_offload struct.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 1f1de20..bd9dd79 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -406,7 +406,6 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
 #endif /* CONFIG_NET_CLS_IND */
 
 struct tc_cls_common_offload {
-	u32 handle;
 	u32 chain_index;
 	__be16 protocol;
 	u32 prio;
@@ -417,7 +416,6 @@ static inline void
 tc_cls_common_offload_init(struct tc_cls_common_offload *cls_common,
 			   const struct tcf_proto *tp)
 {
-	cls_common->handle = tp->q->handle;
 	cls_common->chain_index = tp->chain->index;
 	cls_common->protocol = tp->protocol;
 	cls_common->prio = tp->prio;
-- 
2.9.3
