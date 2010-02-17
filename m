From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 06/18] igb: call pci_save_state after
	pci_restore_state
Date: Wed, 17 Feb 2010 03:02:19 -0800
Message-ID: <20100217110218.17723.84716.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:58932
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753021Ab0BQLCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:02:37 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This patch adds calls to pci_save_state() immediately after
calls to pci_restore_state(). Due to a change in the behavior
of pci_restore_state() it is necessary to call pci_save_state()
to keep the state_saved flag. This patch is based on a similar
patch for ixgbe.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 0427e7c..089a7c3 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5885,6 +5885,7 @@ static int igb_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	pci_save_state(pdev);
 
 	err = pci_enable_device_mem(pdev);
 	if (err) {
@@ -6010,6 +6011,7 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
 	} else {
 		pci_set_master(pdev);
 		pci_restore_state(pdev);
+		pci_save_state(pdev);
 
 		pci_enable_wake(pdev, PCI_D3hot, 0);
 		pci_enable_wake(pdev, PCI_D3cold, 0);

