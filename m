From: Antti Paila <antti.paila@gmail.com>
Subject: [PATCH] ip: Preserve original portocol family in batch mode
Date: Fri, 31 Jul 2015 13:55:31 +0300
Message-ID: <1438340131-13882-1-git-send-email-antti.paila@stonesoft.com>
Cc: Antti Paila <antti.paila@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33041 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbbGaKz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 06:55:59 -0400
Received: by lbbyj8 with SMTP id yj8so43916323lbb.0
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 03:55:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antti Paila <antti.paila@gmail.com>

Reset the 'preferred_family' global variable
to its initially set value before each batch
file command is processed.

Signed-off-by: Antti Paila <antti.paila@gmail.com>
---
 ip/ip.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ip/ip.c b/ip/ip.c
index 3d993b9..0cf743f 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -118,6 +118,7 @@ static int batch(const char *name)
 	char *line = NULL;
 	size_t len = 0;
 	int ret = EXIT_SUCCESS;
+	int orig_family = preferred_family;
 
 	batch_mode = 1;
 
@@ -140,6 +141,8 @@ static int batch(const char *name)
 		char *largv[100];
 		int largc;
 
+		preferred_family = orig_family;
+
 		largc = makeargs(line, largv, 100);
 		if (largc == 0)
 			continue;	/* blank line */
-- 
1.9.1
