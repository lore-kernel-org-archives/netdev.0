From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv1 NEXT 1/7] qlcnic: fix aer for virtual func
Date: Thu, 12 Aug 2010 04:28:41 -0700
Message-ID: <1281612527-27838-2-git-send-email-amit.salecha@qlogic.com>
References: <1281612527-27838-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:63278 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753745Ab0HLL2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 07:28:48 -0400
In-Reply-To: <1281612527-27838-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Virtual function are not privilge to initialize firmware.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index b9615bd..9cc8732 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2723,7 +2723,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	if (qlcnic_api_lock(adapter))
 		return -EINVAL;
 
-	if (first_func) {
+	if (adapter->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
 		adapter->need_fw_reset = 1;
 		set_bit(__QLCNIC_START_FW, &adapter->state);
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
-- 
1.6.0.2

