From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ipv4: make fib_detect_death static
Date: Fri, 27 Dec 2013 12:10:53 -0800
Message-ID: <20131227121053.5f3445ac@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35476 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684Ab3L0UKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 15:10:55 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so9233279pdj.5
        for <netdev@vger.kernel.org>; Fri, 27 Dec 2013 12:10:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make fib_detect_death function static only used in one file.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 net/ipv4/fib_lookup.h    |    2 --
 net/ipv4/fib_semantics.c |    2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

--- a/net/ipv4/fib_lookup.h	2013-12-24 15:15:26.849740111 -0800
+++ b/net/ipv4/fib_lookup.h	2013-12-24 15:15:59.393302735 -0800
@@ -33,8 +33,6 @@ int fib_dump_info(struct sk_buff *skb, u
 void rtmsg_fib(int event, __be32 key, struct fib_alias *fa, int dst_len,
 	       u32 tb_id, const struct nl_info *info, unsigned int nlm_flags);
 struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio);
-int fib_detect_death(struct fib_info *fi, int order,
-		     struct fib_info **last_resort, int *last_idx, int dflt);
 
 static inline void fib_result_assign(struct fib_result *res,
 				     struct fib_info *fi)
--- a/net/ipv4/fib_semantics.c	2013-12-24 15:15:26.849740111 -0800
+++ b/net/ipv4/fib_semantics.c	2013-12-24 15:15:59.393302735 -0800
@@ -426,7 +426,7 @@ struct fib_alias *fib_find_alias(struct
 	return NULL;
 }
 
-int fib_detect_death(struct fib_info *fi, int order,
+static int fib_detect_death(struct fib_info *fi, int order,
 		     struct fib_info **last_resort, int *last_idx, int dflt)
 {
 	struct neighbour *n;
