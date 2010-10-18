From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 3/6] bnx2x: do not deal with power if no
 capability
Date: Mon, 18 Oct 2010 11:10:02 +0200
Message-ID: <1287393002.11597.42.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1978 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754625Ab0JRJM0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 05:12:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 3f0540c..9a3208e 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1520,6 +1520,12 @@ int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 {
 	u16 pmcsr;
 
+	/* If there is no power capability, silently succeed */
+	if (!bp->pm_cap) {
+		DP(NETIF_MSG_HW, "No power capability. Breaking.\n");
+		return 0;
+	}
+
 	pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL, &pmcsr);
 
 	switch (state) {
-- 
1.7.1





