From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/2] qla3xxx: bugfix:  Fix VLAN rx completion handling.
Date: Mon,  1 Oct 2007 11:43:23 -0700
Message-ID: <11912642032225-git-send-email-ron.mercer@qlogic.com>
References: <20071001184141.GA22534@linux-7mw0.qlogic.org>
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:21833 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbXJASnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 14:43:19 -0400
In-Reply-To: <20071001184141.GA22534@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix 4032 chip undocumented "feature" where bit-8 is set
if the inbound completion is for a VLAN.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index c3fe1c7..ea15131 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2249,6 +2249,12 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 
 		net_rsp = qdev->rsp_current;
 		rmb();
+		/*
+		 * Fix 4032 chipe undocumented "feature" where bit-8 is set if the
+		 * inbound completion is for a VLAN.
+		 */
+		if (qdev->device_id == QL3032_DEVICE_ID)
+			net_rsp->opcode &= 0x7f;
 		switch (net_rsp->opcode) {
 
 		case OPCODE_OB_MAC_IOCB_FN0:
-- 
1.5.0.rc4.16.g9e258

