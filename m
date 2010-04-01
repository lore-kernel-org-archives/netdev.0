From: Stefan Assmann <sassmann@redhat.com>
Subject: [PATCH net-next-2.6] igb: restrict WoL for 82576 ET2 Quad Port Server
 Adapter
Date: Thu, 01 Apr 2010 19:00:44 +0200
Message-ID: <4BB4D13C.8030303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	jeffrey.t.kirsher@intel.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752562Ab0DARAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 13:00:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>

Restrict Wake-on-LAN to first port on 82576 ET2 quad port NICs, as it is
only supported there.

Signed-off-by: Stefan Assmann <sassmann@redhat.com>
---
 drivers/net/igb/igb_ethtool.c |    1 +
 drivers/net/igb/igb_main.c    |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 1d4ee41..cdebfbf 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1863,6 +1863,7 @@ static int igb_wol_exclusion(struct igb_adapter *adapter,
 		retval = 0;
 		break;
 	case E1000_DEV_ID_82576_QUAD_COPPER:
+	case E1000_DEV_ID_82576_QUAD_COPPER_ET2:
 		/* quad port adapters only support WoL on port A */
 		if (!(adapter->flags & IGB_FLAG_QUAD_PORT_A)) {
 			wol->supported = 0;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ea87570..5426f41 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1597,6 +1597,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 			adapter->eeprom_wol = 0;
 		break;
 	case E1000_DEV_ID_82576_QUAD_COPPER:
+	case E1000_DEV_ID_82576_QUAD_COPPER_ET2:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
 			adapter->eeprom_wol = 0;
-- 
1.6.6.1

