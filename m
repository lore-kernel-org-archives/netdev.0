From: frank.blaschka@de.ibm.com
Subject: [patch 4/5] qeth: Prepare-function to call s390dbf was wrong
Date: Fri, 06 Jun 2008 12:37:47 +0200
Message-ID: <20080606103829.729388000@de.ibm.com>
References: <20080606103743.638691000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:50449 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972AbYFFKi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:38:56 -0400
Content-Disposition: inline; filename=603-qeth-s390dbf.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

Prepare-function to call s390dbf was wrong handling variable arguments.
This worked as macro but not as function any more.
Now using va_list processing.

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2008-06-06 10:53:13.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2008-06-06 10:53:13.000000000 +0200
@@ -3983,15 +3983,17 @@ static void qeth_unregister_dbf_views(vo
 	}
 }
 
-void qeth_dbf_longtext(enum qeth_dbf_names dbf_nix, int level, char *text, ...)
+void qeth_dbf_longtext(enum qeth_dbf_names dbf_nix, int level, char *fmt, ...)
 {
 	char dbf_txt_buf[32];
+	va_list args;
 
 	if (level > (qeth_dbf[dbf_nix].id)->level)
 		return;
-	snprintf(dbf_txt_buf, sizeof(dbf_txt_buf), text);
+	va_start(args, fmt);
+	vsnprintf(dbf_txt_buf, sizeof(dbf_txt_buf), fmt, args);
+	va_end(args);
 	debug_text_event(qeth_dbf[dbf_nix].id, level, dbf_txt_buf);
-	
 }
 EXPORT_SYMBOL_GPL(qeth_dbf_longtext);
 

-- 
