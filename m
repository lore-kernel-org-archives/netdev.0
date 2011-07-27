From: frank.blaschka@de.ibm.com
Subject: [patch 09/11] [PATCH] qeth: support forced signal adapter indications
Date: Wed, 27 Jul 2011 18:12:51 +0200
Message-ID: <20110727161339.313980198@de.ibm.com>
References: <20110727161242.018577444@de.ibm.com>
Cc: Einar Lueck <elelueck@de.ibm.com>
To: netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:36096 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743Ab1G0QNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 12:13:55 -0400
Content-Disposition: inline; filename=net1117_qeth_siga_r.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Lueck <elelueck@de.ibm.com>

This patch ensures that signal adapter commands are issued if they are
indicated to be required.

Signed-off-by: Einar Lueck <elelueck@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -231,7 +231,8 @@ static inline int qeth_is_ipa_enabled(st
 #define QETH_IN_BUF_COUNT_MAX 128
 #define QETH_MAX_BUFFER_ELEMENTS(card) ((card)->qdio.in_buf_size >> 12)
 #define QETH_IN_BUF_REQUEUE_THRESHOLD(card) \
-		((card)->qdio.in_buf_pool.buf_count / 2)
+		((card)->ssqd.qdioac1 & AC1_SIGA_INPUT_NEEDED ? 1 : \
+		 ((card)->qdio.in_buf_pool.buf_count / 2))
 
 /* buffers we have to be behind before we get a PCI */
 #define QETH_PCI_THRESHOLD_A(card) ((card)->qdio.in_buf_pool.buf_count+1)

