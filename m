From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/4] cnic: Read bnx2x function number from
 internal register
Date: Wed, 27 Jun 2012 18:08:20 -0700
Message-ID: <1340845704-12580-2-git-send-email-mchan@broadcom.com>
References: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4747 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754206Ab2F1A5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 20:57:25 -0400
In-Reply-To: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

so that it will work on any hypervisor.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 31b05ad..5980443 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -4988,8 +4988,14 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	cp->port_mode = CHIP_PORT_MODE_NONE;
 
 	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
-		u32 val = CNIC_RD(dev, MISC_REG_PORT4MODE_EN_OVWR);
+		u32 val;
+
+		pci_read_config_dword(dev->pcidev, PCICFG_ME_REGISTER, &val);
+		cp->func = (u8) ((val & ME_REG_ABS_PF_NUM) >>
+				 ME_REG_ABS_PF_NUM_SHIFT);
+		func = CNIC_FUNC(cp);
 
+		val = CNIC_RD(dev, MISC_REG_PORT4MODE_EN_OVWR);
 		if (!(val & 1))
 			val = CNIC_RD(dev, MISC_REG_PORT4MODE_EN);
 		else
-- 
1.7.1
