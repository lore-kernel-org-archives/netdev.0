From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] sched action: make local function static
Date: Tue, 31 Dec 2013 11:54:00 -0800
Message-ID: <20131231115400.6e85bd34@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:42449 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756485Ab3LaTyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 14:54:04 -0500
Received: by mail-pa0-f52.google.com with SMTP id ld10so13062305pab.39
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 11:54:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to export functions only used in one file.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/net/act_api.h	2013-12-30 21:34:18.394981566 -0800
+++ b/include/net/act_api.h	2013-12-30 21:34:51.862553923 -0800
@@ -105,10 +105,7 @@ struct tcf_common *tcf_hash_lookup(u32 i
 void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo);
 int tcf_hash_release(struct tcf_common *p, int bind,
 		     struct tcf_hashinfo *hinfo);
-int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
-		       int type, struct tc_action *a);
 u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo);
-int tcf_hash_search(struct tc_action *a, u32 index);
 struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a,
 				  int bind, struct tcf_hashinfo *hinfo);
 struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
--- a/net/sched/act_api.c	2013-12-30 21:34:18.394981566 -0800
+++ b/net/sched/act_api.c	2013-12-30 21:34:51.862553923 -0800
@@ -141,8 +141,8 @@ nla_put_failure:
 	return -EINVAL;
 }
 
-int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
-		       int type, struct tc_action *a)
+static int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
+			      int type, struct tc_action *a)
 {
 	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 
@@ -155,7 +155,6 @@ int tcf_generic_walker(struct sk_buff *s
 		return -EINVAL;
 	}
 }
-EXPORT_SYMBOL(tcf_generic_walker);
 
 struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
 {
@@ -187,7 +186,7 @@ u32 tcf_hash_new_index(u32 *idx_gen, str
 }
 EXPORT_SYMBOL(tcf_hash_new_index);
 
-int tcf_hash_search(struct tc_action *a, u32 index)
+static int tcf_hash_search(struct tc_action *a, u32 index)
 {
 	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = tcf_hash_lookup(index, hinfo);
@@ -198,7 +197,6 @@ int tcf_hash_search(struct tc_action *a,
 	}
 	return 0;
 }
-EXPORT_SYMBOL(tcf_hash_search);
 
 struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind,
 				  struct tcf_hashinfo *hinfo)
