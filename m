From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/2] AFS: Make the match_*() functions take const options
Date: Tue, 01 May 2007 18:47:47 +0100
Message-ID: <20070501174747.19112.1985.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, geert@linux-m68k.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755110AbXEARrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 13:47:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the match_*() functions take a const pointer to the options table and
make strings pointers in the options table const too.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/parser.h |    8 ++++----
 lib/parser.c           |   10 +++++-----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/parser.h b/include/linux/parser.h
index fa33328..86676f6 100644
--- a/include/linux/parser.h
+++ b/include/linux/parser.h
@@ -11,10 +11,10 @@
 /* associates an integer enumerator with a pattern string. */
 struct match_token {
 	int token;
-	char *pattern;
+	const char *pattern;
 };
 
-typedef struct match_token match_table_t[];
+typedef const struct match_token match_table_t[];
 
 /* Maximum number of arguments that match_token will find in a pattern */
 enum {MAX_OPT_ARGS = 3};
@@ -29,5 +29,5 @@ int match_token(char *, match_table_t table, substring_t args[]);
 int match_int(substring_t *, int *result);
 int match_octal(substring_t *, int *result);
 int match_hex(substring_t *, int *result);
-void match_strcpy(char *, substring_t *);
-char *match_strdup(substring_t *);
+void match_strcpy(char *, const substring_t *);
+char *match_strdup(const substring_t *);
diff --git a/lib/parser.c b/lib/parser.c
index 7ad2a48..703c8c1 100644
--- a/lib/parser.c
+++ b/lib/parser.c
@@ -22,7 +22,7 @@
  * match extremely simple token=arg style patterns. If the pattern is found,
  * the location(s) of the arguments will be returned in the @args array.
  */
-static int match_one(char *s, char *p, substring_t args[])
+static int match_one(char *s, const char *p, substring_t args[])
 {
 	char *meta;
 	int argc = 0;
@@ -43,7 +43,7 @@ static int match_one(char *s, char *p, substring_t args[])
 		p = meta + 1;
 
 		if (isdigit(*p))
-			len = simple_strtoul(p, &p, 10);
+			len = simple_strtoul(p, (char **) &p, 10);
 		else if (*p == '%') {
 			if (*s++ != '%')
 				return 0;
@@ -102,7 +102,7 @@ static int match_one(char *s, char *p, substring_t args[])
  */
 int match_token(char *s, match_table_t table, substring_t args[])
 {
-	struct match_token *p;
+	const struct match_token *p;
 
 	for (p = table; !match_one(s, p->pattern, args) ; p++)
 		;
@@ -190,7 +190,7 @@ int match_hex(substring_t *s, int *result)
  * &substring_t @s to the c-style string @to. Caller guarantees that @to is
  * large enough to hold the characters of @s.
  */
-void match_strcpy(char *to, substring_t *s)
+void match_strcpy(char *to, const substring_t *s)
 {
 	memcpy(to, s->from, s->to - s->from);
 	to[s->to - s->from] = '\0';
@@ -204,7 +204,7 @@ void match_strcpy(char *to, substring_t *s)
  * the &substring_t @s. The caller is responsible for freeing the returned
  * string with kfree().
  */
-char *match_strdup(substring_t *s)
+char *match_strdup(const substring_t *s)
 {
 	char *p = kmalloc(s->to - s->from + 1, GFP_KERNEL);
 	if (p)

