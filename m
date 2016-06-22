From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v4 1/5] json_writer: Removed automatic json-object type from the constructor
Date: Wed, 22 Jun 2016 06:45:51 -0700
Message-ID: <1466603155-53768-2-git-send-email-roopa@cumulusnetworks.com>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35692 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbcFVNqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 09:46:01 -0400
Received: by mail-pf0-f177.google.com with SMTP id c2so18011456pfa.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 06:46:01 -0700 (PDT)
In-Reply-To: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

Top level can be any json type and can be created using
jsonw_start_object/jsonw_end_object etc.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
---
 lib/json_writer.c | 8 ++++----
 misc/ifstat.c     | 7 +++++++
 misc/nstat.c      | 6 ++++++
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/lib/json_writer.c b/lib/json_writer.c
index 2af16e1..9fc05e9 100644
--- a/lib/json_writer.c
+++ b/lib/json_writer.c
@@ -33,7 +33,7 @@ struct json_writer {
 static void jsonw_indent(json_writer_t *self)
 {
 	unsigned i;
-	for (i = 0; i <= self->depth; ++i)
+	for (i = 0; i < self->depth; ++i)
 		fputs("    ", self->out);
 }
 
@@ -102,7 +102,6 @@ json_writer_t *jsonw_new(FILE *f)
 		self->depth = 0;
 		self->pretty = false;
 		self->sep = '\0';
-		putc('{', self->out);
 	}
 	return self;
 }
@@ -113,8 +112,7 @@ void jsonw_destroy(json_writer_t **self_p)
 	json_writer_t *self = *self_p;
 
 	assert(self->depth == 0);
-	jsonw_eol(self);
-	fputs("}\n", self->out);
+	fputs("\n", self->out);
 	fflush(self->out);
 	free(self);
 	*self_p = NULL;
@@ -269,6 +267,7 @@ int main(int argc, char **argv)
 {
 	json_writer_t *wr = jsonw_new(stdout);
 
+	jsonw_start_object(wr);
 	jsonw_pretty(wr, true);
 	jsonw_name(wr, "Vyatta");
 	jsonw_start_object(wr);
@@ -305,6 +304,7 @@ int main(int argc, char **argv)
 
 	jsonw_end_object(wr);
 
+	jsonw_end_object(wr);
 	jsonw_destroy(&wr);
 	return 0;
 }
diff --git a/misc/ifstat.c b/misc/ifstat.c
index abbb4e7..d551973 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -245,6 +245,7 @@ static void dump_raw_db(FILE *fp, int to_hist)
 
 	h = hist_db;
 	if (jw) {
+		jsonw_start_object(jw);
 		jsonw_pretty(jw, pretty);
 		jsonw_name(jw, info_source);
 		jsonw_start_object(jw);
@@ -288,6 +289,8 @@ static void dump_raw_db(FILE *fp, int to_hist)
 	}
 	if (jw) {
 		jsonw_end_object(jw);
+
+		jsonw_end_object(jw);
 		jsonw_destroy(&jw);
 	}
 }
@@ -451,6 +454,7 @@ static void dump_kern_db(FILE *fp)
 	struct ifstat_ent *n;
 
 	if (jw) {
+		jsonw_start_object(jw);
 		jsonw_pretty(jw, pretty);
 		jsonw_name(jw, info_source);
 		jsonw_start_object(jw);
@@ -477,6 +481,7 @@ static void dump_incr_db(FILE *fp)
 
 	h = hist_db;
 	if (jw) {
+		jsonw_start_object(jw);
 		jsonw_pretty(jw, pretty);
 		jsonw_name(jw, info_source);
 		jsonw_start_object(jw);
@@ -509,6 +514,8 @@ static void dump_incr_db(FILE *fp)
 
 	if (jw) {
 		jsonw_end_object(jw);
+
+		jsonw_end_object(jw);
 		jsonw_destroy(&jw);
 	}
 }
diff --git a/misc/nstat.c b/misc/nstat.c
index a9e0f20..8bd3a1a 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -284,6 +284,7 @@ static void dump_kern_db(FILE *fp, int to_hist)
 
 	h = hist_db;
 	if (jw) {
+		jsonw_start_object(jw);
 		jsonw_pretty(jw, pretty);
 		jsonw_name(jw, info_source);
 		jsonw_start_object(jw);
@@ -317,6 +318,8 @@ static void dump_kern_db(FILE *fp, int to_hist)
 
 	if (jw) {
 		jsonw_end_object(jw);
+
+		jsonw_end_object(jw);
 		jsonw_destroy(&jw);
 	}
 }
@@ -328,6 +331,7 @@ static void dump_incr_db(FILE *fp)
 
 	h = hist_db;
 	if (jw) {
+		jsonw_start_object(jw);
 		jsonw_pretty(jw, pretty);
 		jsonw_name(jw, info_source);
 		jsonw_start_object(jw);
@@ -364,6 +368,8 @@ static void dump_incr_db(FILE *fp)
 
 	if (jw) {
 		jsonw_end_object(jw);
+
+		jsonw_end_object(jw);
 		jsonw_destroy(&jw);
 	}
 }
-- 
1.9.1
