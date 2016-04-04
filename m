From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: fix a memory leak in tc action
Date: Mon,  4 Apr 2016 10:32:48 -0700
Message-ID: <1459791168-16675-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33600 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799AbcDDRc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 13:32:58 -0400
Received: by mail-pf0-f174.google.com with SMTP id 184so48771518pff.0
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 10:32:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for tc actions")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Tested-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 2a19fe1..03e322b 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -135,6 +135,7 @@ void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
 static inline void tc_action_net_exit(struct tc_action_net *tn)
 {
 	tcf_hashinfo_destroy(tn->ops, tn->hinfo);
+	kfree(tn->hinfo);
 }
 
 int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
-- 
2.1.0
