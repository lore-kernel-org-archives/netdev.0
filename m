From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 2/5] be2net: use common method to check for sriov
 function type
Date: Wed, 6 Apr 2011 23:08:01 -0500
Message-ID: <20110407040801.GA4199@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55047 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750762Ab1DGEIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 00:08:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lancer and BE can both use SLI_INTF_REG to check a VF or a PF.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 8941b98..eba405b 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -458,18 +458,10 @@ static inline u8 is_udp_pkt(struct sk_buff *skb)
 
 static inline void be_check_sriov_fn_type(struct be_adapter *adapter)
 {
-	u8 data;
 	u32 sli_intf;
 
-	if (lancer_chip(adapter)) {
-		pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET,
-								&sli_intf);
-		adapter->is_virtfn = (sli_intf & SLI_INTF_FT_MASK) ? 1 : 0;
-	} else {
-		pci_write_config_byte(adapter->pdev, 0xFE, 0xAA);
-		pci_read_config_byte(adapter->pdev, 0xFE, &data);
-		adapter->is_virtfn = (data != 0xAA);
-	}
+	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
+	adapter->is_virtfn = (sli_intf & SLI_INTF_FT_MASK) ? 1 : 0;
 }
 
 static inline void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
-- 
1.7.1

