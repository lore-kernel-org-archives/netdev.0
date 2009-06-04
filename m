From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/6] ixgbe: Enable ACPI WoL capabilities for 82599
Date: Thu, 04 Jun 2009 14:09:58 -0700
Message-ID: <20090604210941.5011.31995.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:46212 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752505AbZFDVKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 17:10:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

The 82599 KX4 device defaults to legacy power management, or APME.  This
puts the device into ACPI mode, which allows more robust WoL setups to
work properly.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index de70a2d..043acab 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5282,6 +5282,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	case IXGBE_DEV_ID_82599_KX4:
 		adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
 		                IXGBE_WUFC_MC | IXGBE_WUFC_BC);
+		/* Enable ACPI wakeup in GRC */
+		IXGBE_WRITE_REG(hw, IXGBE_GRC,
+		             (IXGBE_READ_REG(hw, IXGBE_GRC) & ~IXGBE_GRC_APME));
 		break;
 	default:
 		adapter->wol = 0;

