From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 08/12] Fix ematch cmp and nbyte syntax help text.
Date: Fri, 12 Oct 2007 10:56:43 +0200
Message-ID: <1192179407-22461-8-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
 <1192179407-22461-2-git-send-email-andreas@fatal.se>
 <1192179407-22461-3-git-send-email-andreas@fatal.se>
 <1192179407-22461-4-git-send-email-andreas@fatal.se>
 <1192179407-22461-5-git-send-email-andreas@fatal.se>
 <1192179407-22461-6-git-send-email-andreas@fatal.se>
 <1192179407-22461-7-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Lionel Elie Mamane <lionel@mamane.lu>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38411 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755045AbXJLI5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:57:49 -0400
In-Reply-To: <1192179407-22461-7-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lionel Elie Mamane <lionel@mamane.lu>

The help/usage screen of ematch cmp and nbyte say recognised symbolic
values for "layer FOO" are link, header and next-header, but the code
does _not_ implement that: it will recognise "next-header" as what is
supposed to be "header" and will not recognise "header". The right
symbolic values seem to be link, network, transport. Here is a patch
that changes the help/usage screen to match the code.
(http://bugs.debian.org/438653)

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 tc/em_cmp.c   |    4 ++--
 tc/em_nbyte.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tc/em_cmp.c b/tc/em_cmp.c
index b8f9b46..ce72a42 100644
--- a/tc/em_cmp.c
+++ b/tc/em_cmp.c
@@ -1,5 +1,5 @@
 /*
- * em_cmp.c		Simle coparison Ematch
+ * em_cmp.c		Simple comparison Ematch
  *
  *		This program is free software; you can distribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -32,7 +32,7 @@ static void cmp_print_usage(FILE *fd)
 	    "Usage: cmp(ALIGN at OFFSET [ ATTRS ] { eq | lt | gt } VALUE)\n" \
 	    "where: ALIGN  := { u8 | u16 | u32 }\n" \
 	    "       ATTRS  := [ layer LAYER ] [ mask MASK ] [ trans ]\n" \
-	    "       LAYER  := { link | header | next-header | 0..%d }\n" \
+	    "       LAYER  := { link | network | transport | 0..%d }\n" \
 	    "\n" \
 	    "Example: cmp(u16 at 3 layer 2 mask 0xff00 gt 20)\n",
 	    TCF_LAYER_MAX);
diff --git a/tc/em_nbyte.c b/tc/em_nbyte.c
index 98f9883..242c361 100644
--- a/tc/em_nbyte.c
+++ b/tc/em_nbyte.c
@@ -32,7 +32,7 @@ static void nbyte_print_usage(FILE *fd)
 	    "Usage: nbyte(NEEDLE at OFFSET [layer LAYER])\n" \
 	    "where: NEEDLE := { string | \"c-escape-sequence\" }\n" \
 	    "       OFFSET := int\n" \
-	    "       LAYER  := { link | header | next-header | 0..%d }\n" \
+	    "       LAYER  := { link | network | transport | 0..%d }\n" \
 	    "\n" \
 	    "Example: nbyte(\"ababa\" at 12 layer 1)\n",
 	    TCF_LAYER_MAX);
-- 
1.5.3.4

