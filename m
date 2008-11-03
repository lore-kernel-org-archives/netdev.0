From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 2/4]bnx2x: PCI configuration bug on big-endian
Date: Mon, 03 Nov 2008 18:11:18 +0200
Message-ID: <1225728678.14568.11.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3896 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755782AbYKCQLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 11:11:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code read nothing but zeros on big-endian (wrong part of the
32bits). This caused poor performance on big-endian machines. Though this
issue did not cause the system to crash, the performance is significantly
better with the fix so I view it as critical bug fix.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_init.h |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 130927c..a6c0b3a 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -564,14 +564,15 @@ static const struct arb_line write_arb_addr[NUM_WR_Q-1] = {
 
 static void bnx2x_init_pxp(struct bnx2x *bp)
 {
+	u16 devctl;
 	int r_order, w_order;
 	u32 val, i;
 
 	pci_read_config_word(bp->pdev,
-			     bp->pcie_cap + PCI_EXP_DEVCTL, (u16 *)&val);
-	DP(NETIF_MSG_HW, "read 0x%x from devctl\n", (u16)val);
-	w_order = ((val & PCI_EXP_DEVCTL_PAYLOAD) >> 5);
-	r_order = ((val & PCI_EXP_DEVCTL_READRQ) >> 12);
+			     bp->pcie_cap + PCI_EXP_DEVCTL, &devctl);
+	DP(NETIF_MSG_HW, "read 0x%x from devctl\n", devctl);
+	w_order = ((devctl & PCI_EXP_DEVCTL_PAYLOAD) >> 5);
+	r_order = ((devctl & PCI_EXP_DEVCTL_READRQ) >> 12);
 
 	if (r_order > MAX_RD_ORD) {
 		DP(NETIF_MSG_HW, "read order of %d  order adjusted to %d\n",
-- 
1.5.4.3




