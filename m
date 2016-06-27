From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next] i40e: add missing link advertise setting
Date: Mon, 27 Jun 2016 15:03:43 +0200
Message-ID: <1467032623-1078-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910AbcF0ND4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 09:03:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding the missing link advertise for some X710 NICs.
This can be observed by simply calling ethtool on the interface.
root@rhel7:~ # ethtool eth0
Settings for eth0:
        Supported ports: [ FIBRE ]
        Supported link modes:   10000baseT/Full
        Supported pause frame use: Symmetric
        Supports auto-negotiation: No
        Advertised link modes:  Not reported
[...]
With fix applied.
root@rhel7:~ # ethtool eth0
Settings for eth0:
        Supported ports: [ FIBRE ]
        Supported link modes:   10000baseT/Full
        Supported pause frame use: Symmetric
        Supports auto-negotiation: No
        Advertised link modes:  10000baseT/Full
[...]

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 5e8d84f..88ef7cb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -453,6 +453,7 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 	case I40E_PHY_TYPE_10GBASE_SFPP_CU:
 	case I40E_PHY_TYPE_10GBASE_AOC:
 		ecmd->supported = SUPPORTED_10000baseT_Full;
+		ecmd->advertising = SUPPORTED_10000baseT_Full;
 		break;
 	case I40E_PHY_TYPE_SGMII:
 		ecmd->supported = SUPPORTED_Autoneg |
-- 
2.5.5
