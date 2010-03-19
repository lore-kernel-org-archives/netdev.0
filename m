From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Fix 82599 KX4 Wake on LAN issue after an
	improper system shutdown
Date: Thu, 18 Mar 2010 18:16:56 -0700
Message-ID: <20100319011656.9385.44064.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:53837
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983Ab0CSBRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 21:17:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Advanced Power Management is disabled for 82599 KX4 connections by
clearing GRC.APME bit, causing it to not wake the system from an
improper system shutdown. By default GRC.APME is enabled and software
is not supposed to clear these settings during adapter probe.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b858a1a..18b5b21 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6246,9 +6246,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	case IXGBE_DEV_ID_82599_KX4:
 		adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
 		                IXGBE_WUFC_MC | IXGBE_WUFC_BC);
-		/* Enable ACPI wakeup in GRC */
-		IXGBE_WRITE_REG(hw, IXGBE_GRC,
-		             (IXGBE_READ_REG(hw, IXGBE_GRC) & ~IXGBE_GRC_APME));
 		break;
 	default:
 		adapter->wol = 0;

