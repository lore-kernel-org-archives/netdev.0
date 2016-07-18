From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] jsonw: Fix indentation of ending "}"
Date: Mon, 18 Jul 2016 09:51:17 +0200
Message-ID: <1468828277-19308-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36536 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbcGRHvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 03:51:21 -0400
Received: by mail-wm0-f67.google.com with SMTP id x83so11362467wma.3
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 00:51:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Fix indentation of the very last "}" which is currently indented,
leaving the last 2 "}" like this:
\t}
\t}
EOF

So fix it to be:
\t}
}
EOF

Fixes fcc16c2287 ("provide common json output formatter")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 lib/json_writer.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/json_writer.c b/lib/json_writer.c
index 2af16e1..4c0f646 100644
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
 
@@ -103,6 +103,7 @@ json_writer_t *jsonw_new(FILE *f)
 		self->pretty = false;
 		self->sep = '\0';
 		putc('{', self->out);
+		++self->depth;
 	}
 	return self;
 }
@@ -112,6 +113,7 @@ void jsonw_destroy(json_writer_t **self_p)
 {
 	json_writer_t *self = *self_p;
 
+	--self->depth;
 	assert(self->depth == 0);
 	jsonw_eol(self);
 	fputs("}\n", self->out);
-- 
2.5.5
