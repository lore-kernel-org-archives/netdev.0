From: frank.blaschka@de.ibm.com
Subject: [patch 2/8] qeth: allow qdio queue element addresses > 2GB
Date: Tue, 01 Apr 2008 10:26:54 +0200
Message-ID: <20080401082741.445104000@de.ibm.com>
References: <20080401082652.754871000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <braunu@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:20994 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753726AbYDAI1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 04:27:44 -0400
Content-Disposition: inline; filename=02-qeth_no_dma_mem.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

OSA-adapters do not have an address limitation for the qdio queue
structures except the MAX storage level of the current processor.
And due to a recent z/VM APAR there is no longer a restriction to
allocate qdio structures below 2 GB.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: git_davem-2.6.26/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_core_main.c	2008-03-26 09:21:08.000000000 +0100
+++ git_davem-2.6.26/drivers/s390/net/qeth_core_main.c	2008-03-31 11:17:33.000000000 +0200
@@ -241,7 +241,7 @@
 			return -ENOMEM;
 		}
 		for (j = 0; j < QETH_MAX_BUFFER_ELEMENTS(card); ++j) {
-			ptr = (void *) __get_free_page(GFP_KERNEL|GFP_DMA);
+			ptr = (void *) __get_free_page(GFP_KERNEL);
 			if (!ptr) {
 				while (j > 0)
 					free_page((unsigned long)
@@ -2000,7 +2000,7 @@
 		return 0;
 
 	card->qdio.in_q = kmalloc(sizeof(struct qeth_qdio_q),
-				  GFP_KERNEL|GFP_DMA);
+				  GFP_KERNEL);
 	if (!card->qdio.in_q)
 		goto out_nomem;
 	QETH_DBF_TEXT(setup, 2, "inq");
@@ -2021,7 +2021,7 @@
 		goto out_freepool;
 	for (i = 0; i < card->qdio.no_out_queues; ++i) {
 		card->qdio.out_qs[i] = kmalloc(sizeof(struct qeth_qdio_out_q),
-					       GFP_KERNEL|GFP_DMA);
+					       GFP_KERNEL);
 		if (!card->qdio.out_qs[i])
 			goto out_freeoutq;
 		QETH_DBF_TEXT_(setup, 2, "outq %i", i);
@@ -2308,7 +2308,7 @@
 			struct qeth_buffer_pool_entry, list);
 	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i) {
 		if (page_count(virt_to_page(entry->elements[i])) > 1) {
-			page = alloc_page(GFP_ATOMIC|GFP_DMA);
+			page = alloc_page(GFP_ATOMIC);
 			if (!page) {
 				return NULL;
 			} else {

-- 
