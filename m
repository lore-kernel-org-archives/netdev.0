From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2.6.20-rc5 6/7] ehea: Added logging off associated errors
Date: Mon, 22 Jan 2007 12:54:50 +0100
Message-ID: <200701221254.50615.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <roscher@de.ibm.com>,
	Stefan Roscher <ossrosch@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:47752 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbXAVLyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 06:54:53 -0500
Content-Disposition: inline
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added logging of error events associated with a specific queue pair

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


 drivers/net/ehea/ehea_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)


diff -Nurp -X dontdiff linux-2.6.20-rc5/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.20-rc5/drivers/net/ehea/ehea_main.c	2007-01-19 14:25:38.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-01-19 14:31:34.000000000 +0100
@@ -558,12 +558,12 @@ static irqreturn_t ehea_qp_aff_irq_handl
 	u32 qp_token;
 
 	eqe = ehea_poll_eq(port->qp_eq);
-	ehea_debug("eqe=%p", eqe);
+
 	while (eqe) {
-		ehea_debug("*eqe=%lx", *(u64*)eqe);
-		eqe = ehea_poll_eq(port->qp_eq);
 		qp_token = EHEA_BMASK_GET(EHEA_EQE_QP_TOKEN, eqe->entry);
-		ehea_debug("next eqe=%p", eqe);
+		ehea_error("QP aff_err: entry=0x%lx, token=0x%x",
+			   eqe->entry, qp_token);
+		eqe = ehea_poll_eq(port->qp_eq);
 	}
 
 	return IRQ_HANDLED;

