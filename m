From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 1/5] net_sched: make tcf_hash_destroy() static
Date: Tue, 25 Aug 2015 20:06:31 -0700
Message-ID: <1440558395-7765-2-git-send-email-ast@plumgrid.com>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35387 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872AbbHZDGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 23:06:44 -0400
Received: by pacdd16 with SMTP id dd16so144535149pac.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 20:06:43 -0700 (PDT)
In-Reply-To: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcf_hash_destroy() used once. Make it static.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/net/act_api.h |    1 -
 net/sched/act_api.c   |    3 +--
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 4519c81304bd..9d446f136607 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -111,7 +111,6 @@ struct tc_action_ops {
 };
 
 int tcf_hash_search(struct tc_action *a, u32 index);
-void tcf_hash_destroy(struct tc_action *a);
 u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo);
 int tcf_hash_check(u32 index, struct tc_action *a, int bind);
 int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index b087087ccfa9..06e7c4a37245 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -36,7 +36,7 @@ static void free_tcf(struct rcu_head *head)
 	kfree(p);
 }
 
-void tcf_hash_destroy(struct tc_action *a)
+static void tcf_hash_destroy(struct tc_action *a)
 {
 	struct tcf_common *p = a->priv;
 	struct tcf_hashinfo *hinfo = a->ops->hinfo;
@@ -52,7 +52,6 @@ void tcf_hash_destroy(struct tc_action *a)
 	 */
 	call_rcu(&p->tcfc_rcu, free_tcf);
 }
-EXPORT_SYMBOL(tcf_hash_destroy);
 
 int __tcf_hash_release(struct tc_action *a, bool bind, bool strict)
 {
-- 
1.7.9.5
