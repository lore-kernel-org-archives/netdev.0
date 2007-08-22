From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 3/4] ehea: fix queue destructor
Date: Wed, 22 Aug 2007 16:21:28 +0200
Message-ID: <200708221621.28487.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:47196 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762556AbXHVOxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 10:53:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Includes hcp_epas_dtor in eq/cq/qp destructors to unmap
HW register.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 drivers/net/ehea/ehea_qmr.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index a36fa6c..c82e245 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -235,6 +235,8 @@ int ehea_destroy_cq(struct ehea_cq *cq)
 	if (!cq)
 		return 0;
 
+	hcp_epas_dtor(&cq->epas);
+
 	if ((hret = ehea_destroy_cq_res(cq, NORMAL_FREE)) == H_R_STATE) {
 		ehea_error_data(cq->adapter, cq->fw_handle);
 		hret = ehea_destroy_cq_res(cq, FORCE_FREE);
@@ -361,6 +363,8 @@ int ehea_destroy_eq(struct ehea_eq *eq)
 	if (!eq)
 		return 0;
 
+	hcp_epas_dtor(&eq->epas);
+
 	if ((hret = ehea_destroy_eq_res(eq, NORMAL_FREE)) == H_R_STATE) {
 		ehea_error_data(eq->adapter, eq->fw_handle);
 		hret = ehea_destroy_eq_res(eq, FORCE_FREE);
@@ -541,6 +545,8 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 	if (!qp)
 		return 0;
 
+	hcp_epas_dtor(&qp->epas);
+
 	if ((hret = ehea_destroy_qp_res(qp, NORMAL_FREE)) == H_R_STATE) {
 		ehea_error_data(qp->adapter, qp->fw_handle);
 		hret = ehea_destroy_qp_res(qp, FORCE_FREE);
-- 
1.5.2

