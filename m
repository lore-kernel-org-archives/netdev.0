From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 18/19] sched: cls_flower: expose priority to offloading netdevice
Date: Thu,  2 Feb 2017 16:12:58 +0100
Message-ID: <1486048379-19237-19-git-send-email-jiri@resnulli.us>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34632 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751983AbdBBPNe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 10:13:34 -0500
Received: by mail-wm0-f68.google.com with SMTP id c85so4691398wmi.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 07:13:28 -0800 (PST)
In-Reply-To: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The driver that offloads flower rules needs to know with which priority
user inserted the rules. So add this information into offload struct.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 include/net/pkt_cls.h  | 1 +
 net/sched/cls_flower.c | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index b43077e..dabb00a 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -481,6 +481,7 @@ enum tc_fl_command {
 
 struct tc_cls_flower_offload {
 	enum tc_fl_command command;
+	u32 prio;
 	unsigned long cookie;
 	struct flow_dissector *dissector;
 	struct fl_flow_key *mask;
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 9e74b0f..e96ced5 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -229,6 +229,7 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 		return;
 
 	offload.command = TC_CLSFLOWER_DESTROY;
+	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
 
 	tc->type = TC_SETUP_CLSFLOWER;
@@ -260,6 +261,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	}
 
 	offload.command = TC_CLSFLOWER_REPLACE;
+	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
 	offload.dissector = dissector;
 	offload.mask = mask;
@@ -287,6 +289,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 		return;
 
 	offload.command = TC_CLSFLOWER_STATS;
+	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
 	offload.exts = &f->exts;
 
-- 
2.7.4
