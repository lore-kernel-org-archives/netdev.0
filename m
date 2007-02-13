From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 3/8]: 5722/5756 don't need PHY jitter workaround.
Date: Tue, 13 Feb 2007 12:14:09 -0800
Message-ID: <1171397649.18944.27.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1745 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802AbXBMTap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:30:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: 5722/5756 don't need PHY jitter workaround.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2df343f..fc94b19 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10779,7 +10779,9 @@ static int __devinit tg3_get_invariants(
 	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) {
-			tp->tg3_flags2 |= TG3_FLG2_PHY_JITTER_BUG;
+			if (tp->pdev->device != PCI_DEVICE_ID_TIGON3_5756 &&
+			    tp->pdev->device != PCI_DEVICE_ID_TIGON3_5722)
+				tp->tg3_flags2 |= TG3_FLG2_PHY_JITTER_BUG;
 			if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5755M)
 				tp->tg3_flags2 |= TG3_FLG2_PHY_ADJUST_TRIM;
 		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)


