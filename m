From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: fix Need to call pci_save_state after
	pci_restore_state
Date: Tue, 22 Dec 2009 12:45:20 -0800
Message-ID: <20091222204456.14196.63456.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:53236
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751402AbZLVUpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 15:45:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds a pci_save_state() call in ixgbe_resume() after
pci_restore_state(). A similar change was made in ixgbe_io_slot_reset()
that accommodates pci_restore_state() new behavior. This change makes
pci_restore_state() clear the saved_state flag This is necessary due
to a resent kernel change to pci_restore_state() so that it now clears
the saved_state flag of the device right after the device.s standard
configuration registers have been poplulated with the previously saved
values.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index bd64387..1a2ea62 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4373,6 +4373,11 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	/*
+	 * pci_restore_state clears dev->state_saved so call
+	 * pci_save_state to restore it.
+	 */
+	pci_save_state(pdev);
 
 	err = pci_enable_device_mem(pdev);
 	if (err) {

