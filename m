From: frank.blaschka@de.ibm.com
Subject: [patch 09/11] qeth: read number of ports from card
Date: Thu, 24 Apr 2008 10:15:26 +0200
Message-ID: <20080424081907.955412000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <braunu@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:11080 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbYDXITK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:10 -0400
Content-Disposition: inline; filename=708-qeth-leftover.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

Read out number of ports from the hardware.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    5 +++--
 include/asm-s390/qdio.h           |    1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

Index: git_linus/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_core_main.c	2008-04-24 08:51:11.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_core_main.c	2008-04-24 08:55:40.000000000 +0200
@@ -3803,8 +3803,9 @@
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		return rc;
 	}
-
-	mpno = QETH_MAX_PORTNO;
+	mpno = qdio_get_ssqd_pct(CARD_DDEV(card));
+	if (mpno)
+		mpno = min(mpno - 1, QETH_MAX_PORTNO);
 	if (card->info.portno > mpno) {
 		PRINT_ERR("Device %s does not offer port number %d \n.",
 			CARD_BUS_ID(card), card->info.portno);
Index: git_linus/include/asm-s390/qdio.h
===================================================================
--- git_linus.orig/include/asm-s390/qdio.h	2008-04-23 14:56:16.000000000 +0200
+++ git_linus/include/asm-s390/qdio.h	2008-04-24 08:53:24.000000000 +0200
@@ -127,6 +127,7 @@
 		   unsigned int qidx,unsigned int count,
 		   struct qdio_buffer *buffers);
 
+extern int qdio_get_ssqd_pct(struct ccw_device*);
 extern int qdio_synchronize(struct ccw_device*, unsigned int flags,
 			    unsigned int queue_number);
 

-- 
