From: frank.blaschka@de.ibm.com
Subject: [patch 3/3] qeth: preallocated header account offset
Date: Fri, 15 Aug 2008 08:03:00 +0200
Message-ID: <20080815060352.948003000@de.ibm.com>
References: <20080815060257.501264000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:33621 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbYHOGED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 02:04:03 -0400
Content-Disposition: inline; filename=602-qeth-prealloc-offset.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

When a preallocated header qdio buffer is filled we have to account
the offset for the data length.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: git_linus/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_core_main.c	2008-08-15 07:51:59.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_core_main.c	2008-08-15 07:52:18.000000000 +0200
@@ -3024,7 +3024,7 @@
 	struct qdio_buffer *buffer, int is_tso, int *next_element_to_fill,
 	int offset)
 {
-	int length = skb->len;
+	int length = skb->len - offset;
 	int length_here;
 	int element;
 	char *data;

-- 
