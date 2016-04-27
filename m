From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 2/2] ip link gre: print only relevant info in external mode
Date: Wed, 27 Apr 2016 16:11:14 +0200
Message-ID: <837a7439aacf528066dfb2a873112e4f2fc00ea6.1461766016.git.jbenc@redhat.com>
References: <cover.1461766016.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pravin Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbcD0OLi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 10:11:38 -0400
In-Reply-To: <cover.1461766016.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Display only attributes that are relevant when a GRE interface is in
'external' mode instead of the default values (which are ignored by the
kernel even if passed back).

Fixes: 926b39e1feffd ("gre: add support for collect metadata flag")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 ip/link_gre.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/ip/link_gre.c b/ip/link_gre.c
index 36ce1252675b..492c22053b89 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -339,7 +339,7 @@ get_failed:
 	return 0;
 }
 
-static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+static void gre_print_direct_opt(FILE *f, struct rtattr *tb[])
 {
 	char s2[64];
 	const char *local = "any";
@@ -347,9 +347,6 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	unsigned int iflags = 0;
 	unsigned int oflags = 0;
 
-	if (!tb)
-		return;
-
 	if (tb[IFLA_GRE_REMOTE]) {
 		unsigned int addr = rta_getattr_u32(tb[IFLA_GRE_REMOTE]);
 
@@ -421,8 +418,16 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fputs("icsum ", f);
 	if (oflags & GRE_CSUM)
 		fputs("ocsum ", f);
+}
 
-	if (tb[IFLA_GRE_COLLECT_METADATA])
+static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	if (!tb)
+		return;
+
+	if (!tb[IFLA_GRE_COLLECT_METADATA])
+		gre_print_direct_opt(f, tb);
+	else
 		fputs("external ", f);
 
 	if (tb[IFLA_GRE_ENCAP_TYPE] &&
-- 
1.8.3.1
