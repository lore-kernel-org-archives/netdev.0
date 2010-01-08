From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/5] e1000e: call pci_save_state() after
	pci_restore_state()
Date: Thu, 07 Jan 2010 18:30:56 -0800
Message-ID: <20100108023033.31476.4034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:33907
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752648Ab0AHCbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 21:31:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Due to a change in pci_restore_state()[1] which clears the saved_state
flag, the driver should call pci_save_state() to set the flag once again
to avoid issues with EEH (same fix that recently was submitted for ixgbe).

[1] commmit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 762b697..10aa0ec 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4674,6 +4674,7 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	pci_save_state(pdev);
 	e1000e_disable_l1aspm(pdev);
 
 	err = pci_enable_device_mem(pdev);
@@ -4825,6 +4826,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	} else {
 		pci_set_master(pdev);
 		pci_restore_state(pdev);
+		pci_save_state(pdev);
 
 		pci_enable_wake(pdev, PCI_D3hot, 0);
 		pci_enable_wake(pdev, PCI_D3cold, 0);

