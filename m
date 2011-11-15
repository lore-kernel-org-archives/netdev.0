From: frank.blaschka@de.ibm.com
Subject: [patch 5/5] [PATCH] qeth: Reduce CPU consumption through less SIGA-r calls
Date: Tue, 15 Nov 2011 13:31:16 +0100
Message-ID: <20111115123152.686856892@de.ibm.com>
References: <20111115123111.128739986@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Einar Lueck <elelueck@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:39059 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab1KOMby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 07:31:54 -0500
Content-Disposition: inline; filename=623-qeth-reduce-siga.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Lueck <elelueck@de.ibm.com>

Patch avoids SIGA-r calls in case of SIGA-r required. It only calls
SIGA-r if a threshold of free buffer is reached. CPU consumption is
reduced as a consequence.

Signed-off-by: Einar Lueck <elelueck@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2011-11-14 18:26:56.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2011-11-14 18:27:18.000000000 +0100
@@ -236,8 +236,7 @@ static inline int qeth_is_ipa_enabled(st
 #define QETH_IN_BUF_COUNT_MAX 128
 #define QETH_MAX_BUFFER_ELEMENTS(card) ((card)->qdio.in_buf_size >> 12)
 #define QETH_IN_BUF_REQUEUE_THRESHOLD(card) \
-		((card)->ssqd.qdioac1 & AC1_SIGA_INPUT_NEEDED ? 1 : \
-		 ((card)->qdio.in_buf_pool.buf_count / 2))
+		 ((card)->qdio.in_buf_pool.buf_count / 2)
 
 /* buffers we have to be behind before we get a PCI */
 #define QETH_PCI_THRESHOLD_A(card) ((card)->qdio.in_buf_pool.buf_count+1)
