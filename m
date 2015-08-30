From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v4 10/10] ss: extended json_writer for hex field and value output
Date: Sun, 30 Aug 2015 15:24:35 +0200
Message-ID: <1440941075-26478-11-git-send-email-matthias.tafelmeier@gmx.net>
References: <1440941075-26478-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:53822 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753503AbbH3NZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Aug 2015 09:25:29 -0400
In-Reply-To: <1440941075-26478-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small patch extendedis the lib json_writer module for hex field
which is needed in the json format handler of ss.

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/json_writer.h |  3 +++
 lib/json_writer.c     | 16 ++++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/json_writer.h b/include/json_writer.h
index ab9a008..6c1581b 100644
--- a/include/json_writer.h
+++ b/include/json_writer.h
@@ -17,6 +17,7 @@
 
 #include <stdbool.h>
 #include <stdint.h>
+#include <stdio.h>
 
 /* Opaque class structure */
 typedef struct json_writer json_writer_t;
@@ -38,6 +39,7 @@ void jsonw_bool(json_writer_t *self, bool value);
 void jsonw_float(json_writer_t *self, double number);
 void jsonw_uint(json_writer_t *self, uint64_t number);
 void jsonw_int(json_writer_t *self, int64_t number);
+void jsonw_hex(json_writer_t *self, uint64_t num);
 void jsonw_null(json_writer_t *self);
 
 /* Useful Combinations of name and value */
@@ -46,6 +48,7 @@ void jsonw_bool_field(json_writer_t *self, const char *prop, bool value);
 void jsonw_float_field(json_writer_t *self, const char *prop, double num);
 void jsonw_uint_field(json_writer_t *self, const char *prop, uint64_t num);
 void jsonw_int_field(json_writer_t *self, const char *prop, int64_t num);
+void jsonw_hex_field(json_writer_t *self, const char *prop, uint64_t num);
 void jsonw_null_field(json_writer_t *self, const char *prop);
 
 /* Collections */
diff --git a/lib/json_writer.c b/lib/json_writer.c
index 2af16e1..495ce57 100644
--- a/lib/json_writer.c
+++ b/lib/json_writer.c
@@ -22,6 +22,8 @@
 
 #include "json_writer.h"
 
+#define notused
+
 struct json_writer {
 	FILE		*out;	/* output file */
 	unsigned	depth;  /* nesting */
@@ -223,6 +225,14 @@ void jsonw_int(json_writer_t *self, int64_t num)
 	jsonw_printf(self, "%"PRId64, num);
 }
 
+void jsonw_hex(json_writer_t *self, uint64_t num)
+{
+	char tmp[17];
+
+	sprintf(tmp, "%"PRIx64, num);
+	jsonw_string(self, tmp);
+}
+
 /* Basic name/value objects */
 void jsonw_string_field(json_writer_t *self, const char *prop, const char *val)
 {
@@ -256,6 +266,12 @@ void jsonw_int_field(json_writer_t *self, const char *prop, int64_t num)
 	jsonw_int(self, num);
 }
 
+void jsonw_hex_field(json_writer_t *self, const char *prop, uint64_t num)
+{
+	jsonw_name(self, prop);
+	jsonw_hex(self, num);
+}
+
 #ifdef notused
 void jsonw_null_field(json_writer_t *self, const char *prop)
 {
-- 
1.9.1
