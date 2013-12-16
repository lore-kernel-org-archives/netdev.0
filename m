From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/10] ipv4: make fib_detect_death static
Date: Mon, 16 Dec 2013 10:36:06 -0800
Message-ID: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:41815 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755401Ab3LPTkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:40:19 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so3367725pab.6
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 11:40:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Make fib_detect_death function static only used in one file.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv4/fib_lookup.h	2013-12-12 11:48:17.293851542 -0800
+++ b/net/ipv4/fib_lookup.h	2013-12-12 11:56:44.461952887 -0800
@@ -33,8 +33,6 @@ int fib_dump_info(struct sk_buff *skb, u
 void rtmsg_fib(int event, __be32 key, struct fib_alias *fa, int dst_len,
 	       u32 tb_id, const struct nl_info *info, unsigned int nlm_flags);
 struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio);
-int fib_detect_death(struct fib_info *fi, int order,
-		     struct fib_info **last_resort, int *last_idx, int dflt);
 
 static inline void fib_result_assign(struct fib_result *res,
 				     struct fib_info *fi)
--- a/net/ipv4/fib_semantics.c	2013-12-12 11:48:17.293851542 -0800
+++ b/net/ipv4/fib_semantics.c	2013-12-12 11:56:44.461952887 -0800
@@ -426,7 +426,7 @@ struct fib_alias *fib_find_alias(struct
 	return NULL;
 }
 
-int fib_detect_death(struct fib_info *fi, int order,
+static int fib_detect_death(struct fib_info *fi, int order,
 		     struct fib_info **last_resort, int *last_idx, int dflt)
 {
 	struct neighbour *n;
