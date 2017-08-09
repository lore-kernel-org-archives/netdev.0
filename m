From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] net: sched: propagate classid down to offload drivers
Date: Wed,  9 Aug 2017 14:30:32 +0200
Message-ID: <20170809123035.7663-3-jiri@resnulli.us>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37477 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbdHIMam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:30:42 -0400
Received: by mail-wm0-f68.google.com with SMTP id t138so6612749wmt.4
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:30:41 -0700 (PDT)
In-Reply-To: <20170809123035.7663-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Drivers need classid to decide they support this specific qdisc+class
or not. So propagate it down via the tc_cls_common_offload struct.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 0f78e65..1f1de20 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -410,6 +410,7 @@ struct tc_cls_common_offload {
 	u32 chain_index;
 	__be16 protocol;
 	u32 prio;
+	u32 classid;
 };
 
 static inline void
@@ -420,6 +421,7 @@ tc_cls_common_offload_init(struct tc_cls_common_offload *cls_common,
 	cls_common->chain_index = tp->chain->index;
 	cls_common->protocol = tp->protocol;
 	cls_common->prio = tp->prio;
+	cls_common->classid = tp->classid;
 }
 
 struct tc_cls_u32_knode {
-- 
2.9.3
