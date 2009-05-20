From: frank.blaschka@de.ibm.com
Subject: [patch 5/5] [PATCH] qeth: Clear SBALF15 in any case for output buffers.
Date: Wed, 20 May 2009 09:38:41 +0200
Message-ID: <20090520073928.212451000@de.ibm.com>
References: <20090520073836.897878000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:57840 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbZETHkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 03:40:23 -0400
Content-Disposition: inline; filename=616-qeth-clear-SBALF15.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacket <kdwacker@de.ibm.com>

Function qeth_clear_output_buffer for HiperSockets may not clear
all 16 SBALEs, but only the used ones. The error flag in SBALF15
has to be cleared in any case.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    1 +
 1 file changed, 1 insertion(+)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2009-05-20 08:56:43.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2009-05-20 08:56:43.000000000 +0200
@@ -952,6 +952,7 @@ static void qeth_clear_output_buffer(str
 		buf->buffer->element[i].addr = NULL;
 		buf->buffer->element[i].flags = 0;
 	}
+	buf->buffer->element[15].flags = 0;
 	buf->next_element_to_fill = 0;
 	atomic_set(&buf->state, QETH_QDIO_BUF_EMPTY);
 }

