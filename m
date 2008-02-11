From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/6] e1000: warn if this driver is used for e1000e devices
Date: Mon, 11 Feb 2008 09:25:46 -0800
Message-ID: <20080211172546.29090.29806.stgit@localhost.localdomain>
References: <20080211172539.29090.99369.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6433 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759464AbYBKR2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 12:28:00 -0500
In-Reply-To: <20080211172539.29090.99369.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're already starting to see reports from users still
using e1000 where they should be using e1000e now that this is
actually possible. Just to prevent some of this thrash, add
a big warning on load on these devices that people should
switch to e1000e.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000/e1000_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7c5b05a..81db7fd 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1203,6 +1203,14 @@ e1000_probe(struct pci_dev *pdev,
 
 	printk("%s\n", print_mac(mac, netdev->dev_addr));
 
+	if (adapter->hw.bus_type == e1000_bus_type_pci_express) {
+		DPRINTK(PROBE, WARNING, "This device (id %04x:%04x) will no "
+			"longer be supported by this driver in the future.\n",
+			pdev->vendor, pdev->device);
+		DPRINTK(PROBE, WARNING, "please use the \"e1000e\" "
+			"driver instead.\n");
+	}
+
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
 

