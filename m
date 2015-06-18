From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH] fm10k: Report MAC address on driver load
Date: Wed, 17 Jun 2015 20:12:52 -0700
Message-ID: <20150618031252.15654.56639.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54829 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbbFRDMx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 23:12:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds the MAC address to the list of values recorded on driver
load.  The MAC address represents the serial number of the unit and allows
us to track the value should a card be replaced in a system.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index df9fda38bdd1..5db41ab3b762 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1837,7 +1837,7 @@ static int fm10k_probe(struct pci_dev *pdev,
 	fm10k_ptp_register(interface);
 
 	/* print bus type/speed/width info */
-	dev_info(&pdev->dev, "(PCI Express:%s Width: %s Payload: %s)\n",
+	dev_info(&pdev->dev, "(PCI Express:%s Width: %s Payload: %s) %pM\n",
 		 (hw->bus.speed == fm10k_bus_speed_8000 ? "8.0GT/s" :
 		  hw->bus.speed == fm10k_bus_speed_5000 ? "5.0GT/s" :
 		  hw->bus.speed == fm10k_bus_speed_2500 ? "2.5GT/s" :
@@ -1849,7 +1849,7 @@ static int fm10k_probe(struct pci_dev *pdev,
 		 (hw->bus.payload == fm10k_bus_payload_128 ? "128B" :
 		  hw->bus.payload == fm10k_bus_payload_256 ? "256B" :
 		  hw->bus.payload == fm10k_bus_payload_512 ? "512B" :
-		  "Unknown"));
+		  "Unknown"), netdev->dev_addr);
 
 	/* print warning for non-optimal configurations */
 	fm10k_slot_warn(interface);
