From: kaber@trash.net
Subject: [PATCH 81/84] netfilter: x_tables: rectify XT_FUNCTION_MAXNAMELEN usage
Date: Mon, 10 May 2010 22:18:52 +0200
Message-ID: <1273522735-24672-82-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54507 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756951Ab0EJUTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:30 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

There has been quite a confusion in userspace about
XT_FUNCTION_MAXNAMELEN; because struct xt_entry_match used MAX-1,
userspace would have to do an awkward MAX-2 for maximum length
checking (due to '\0'). This patch adds a new define that matches the
definition of XT_TABLE_MAXNAMELEN - being the size of the actual
struct member, not one off.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/x_tables.h |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 50c8672..eeb4884 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 
 #define XT_FUNCTION_MAXNAMELEN 30
+#define XT_EXTENSION_MAXNAMELEN 29
 #define XT_TABLE_MAXNAMELEN 32
 
 struct xt_entry_match {
@@ -12,8 +13,7 @@ struct xt_entry_match {
 			__u16 match_size;
 
 			/* Used by userspace */
-			char name[XT_FUNCTION_MAXNAMELEN-1];
-
+			char name[XT_EXTENSION_MAXNAMELEN];
 			__u8 revision;
 		} user;
 		struct {
@@ -36,8 +36,7 @@ struct xt_entry_target {
 			__u16 target_size;
 
 			/* Used by userspace */
-			char name[XT_FUNCTION_MAXNAMELEN-1];
-
+			char name[XT_EXTENSION_MAXNAMELEN];
 			__u8 revision;
 		} user;
 		struct {
@@ -70,8 +69,7 @@ struct xt_standard_target {
 /* The argument to IPT_SO_GET_REVISION_*.  Returns highest revision
  * kernel supports, if >= revision. */
 struct xt_get_revision {
-	char name[XT_FUNCTION_MAXNAMELEN-1];
-
+	char name[XT_EXTENSION_MAXNAMELEN];
 	__u8 revision;
 };
 
@@ -291,7 +289,7 @@ struct xt_tgdtor_param {
 struct xt_match {
 	struct list_head list;
 
-	const char name[XT_FUNCTION_MAXNAMELEN-1];
+	const char name[XT_EXTENSION_MAXNAMELEN];
 	u_int8_t revision;
 
 	/* Return true or false: return FALSE and set *hotdrop = 1 to
@@ -330,7 +328,7 @@ struct xt_match {
 struct xt_target {
 	struct list_head list;
 
-	const char name[XT_FUNCTION_MAXNAMELEN-1];
+	const char name[XT_EXTENSION_MAXNAMELEN];
 	u_int8_t revision;
 
 	/* Returns verdict. Argument order changed since 2.6.9, as this
-- 
1.7.0.4

