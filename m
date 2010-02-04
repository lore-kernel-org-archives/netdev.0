From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] e1000: call pci_save_state after
	pci_restore_state
Date: Wed, 03 Feb 2010 16:49:48 -0800
Message-ID: <20100204004947.16084.75922.stgit@localhost.localdomain>
References: <20100204004926.16084.32526.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:45695
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933018Ab0BDAuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 19:50:06 -0500
In-Reply-To: <20100204004926.16084.32526.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This patch adds a call to pci_save_state() immediately after
the call to pci_restore_state(). Due to a change in the behavior
of pci_restore_state() it is necessary to call pci_save_state()
to keep the state_saved flag. This patch is based on a similar
patch for ixgbe.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4ff50d6..3b14dd7 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -847,6 +847,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 
 	pci_set_master(pdev);
+	err = pci_save_state(pdev);
+	if (err)
+		goto err_alloc_etherdev;
 
 	err = -ENOMEM;
 	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
@@ -4596,6 +4599,7 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	pci_save_state(pdev);
 
 	if (adapter->need_ioport)
 		err = pci_enable_device(pdev);

