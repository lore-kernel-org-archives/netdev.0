From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 2/2] igb/ixgbe: add code to trigger function reset if
	reset_devices is set
Date: Fri, 30 Jul 2010 17:59:12 -0700
Message-ID: <20100731005910.32625.89518.stgit@localhost.localdomain>
References: <20100731005803.32625.6891.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, jbarnes@virtuousgeek.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:44382
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753366Ab0GaA7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 20:59:33 -0400
In-Reply-To: <20100731005803.32625.6891.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that both igb and ixgbe can trigger a full pcie
function reset if the reset_devices kernel parameter is defined.  The main
reason for adding this is that kdump can cause serious issues when the
kdump kernel resets the IOMMU while DMA transactions are still occurring.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c     |    3 +++
 drivers/net/ixgbe/ixgbe_main.c |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 667b527..b924443 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1731,6 +1731,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		return -EINVAL;
 	}
 
+	if (reset_devices && pci_reset_device_function(pdev))
+		return -ENODEV;
+
 	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7d6a415..f459f24 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6548,6 +6548,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		return -EINVAL;
 	}
 
+	if (reset_devices && pci_reset_device_function(pdev))
+		return -ENODEV;
+
 	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;

