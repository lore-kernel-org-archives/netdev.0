From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netfilter: xtables make functions local
Date: Fri, 27 Dec 2013 12:09:37 -0800
Message-ID: <20131227120937.702bc383@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34025 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754722Ab3L0UJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 15:09:40 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so9632417pab.14
        for <netdev@vger.kernel.org>; Fri, 27 Dec 2013 12:09:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of functions only used in x_tables, don't need to be global

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/linux/netfilter/x_tables.h |    2 --
 net/netfilter/x_tables.c           |    6 ++----
 2 files changed, 2 insertions(+), 6 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2013-12-24 15:14:54.502174551 -0800
+++ b/include/linux/netfilter/x_tables.h	2013-12-24 15:16:01.889269178 -0800
@@ -255,8 +255,6 @@ struct xt_table_info *xt_replace_table(s
 				       struct xt_table_info *newinfo,
 				       int *error);
 
-struct xt_match *xt_find_match(u8 af, const char *name, u8 revision);
-struct xt_target *xt_find_target(u8 af, const char *name, u8 revision);
 struct xt_match *xt_request_find_match(u8 af, const char *name, u8 revision);
 struct xt_target *xt_request_find_target(u8 af, const char *name, u8 revision);
 int xt_find_revision(u8 af, const char *name, u8 revision, int target,
--- a/net/netfilter/x_tables.c	2013-12-24 15:14:54.502174551 -0800
+++ b/net/netfilter/x_tables.c	2013-12-24 15:16:01.889269178 -0800
@@ -189,7 +189,7 @@ EXPORT_SYMBOL(xt_unregister_matches);
  */
 
 /* Find match, grabs ref.  Returns ERR_PTR() on error. */
-struct xt_match *xt_find_match(u8 af, const char *name, u8 revision)
+static struct xt_match *xt_find_match(u8 af, const char *name, u8 revision)
 {
 	struct xt_match *m;
 	int err = -ENOENT;
@@ -216,7 +216,6 @@ struct xt_match *xt_find_match(u8 af, co
 
 	return ERR_PTR(err);
 }
-EXPORT_SYMBOL(xt_find_match);
 
 struct xt_match *
 xt_request_find_match(uint8_t nfproto, const char *name, uint8_t revision)
@@ -234,7 +233,7 @@ xt_request_find_match(uint8_t nfproto, c
 EXPORT_SYMBOL_GPL(xt_request_find_match);
 
 /* Find target, grabs ref.  Returns ERR_PTR() on error. */
-struct xt_target *xt_find_target(u8 af, const char *name, u8 revision)
+static struct xt_target *xt_find_target(u8 af, const char *name, u8 revision)
 {
 	struct xt_target *t;
 	int err = -ENOENT;
@@ -261,7 +260,6 @@ struct xt_target *xt_find_target(u8 af,
 
 	return ERR_PTR(err);
 }
-EXPORT_SYMBOL(xt_find_target);
 
 struct xt_target *xt_request_find_target(u8 af, const char *name, u8 revision)
 {
