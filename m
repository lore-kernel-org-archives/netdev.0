From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igb: restrict WoL for 82576 ET2 Quad Port Server
	Adapter
Date: Fri, 09 Apr 2010 12:51:34 -0700
Message-ID: <20100409195029.30616.21221.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Stefan Assmann <sassmann@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:40434
	"EHLO qmta07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756322Ab0DITv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 15:51:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>

Restrict Wake-on-LAN to first port on 82576 ET2 quad port NICs, as it is
only supported there.

Signed-off-by: Stefan Assmann <sassmann@redhat.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
index 2745e17..876a49b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1593,6 +1593,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 			adapter->eeprom_wol = 0;
 		break;
 	case E1000_DEV_ID_82576_QUAD_COPPER:
+	case E1000_DEV_ID_82576_QUAD_COPPER_ET2:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
 			adapter->eeprom_wol = 0;

