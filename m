From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 02/23] e100, e1000, ixgb: Fix an impossible memory overwrite bug
Date: Tue, 19 Sep 2006 10:28:36 -0700
Message-ID: <20060919172836.4605.29394.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:10765 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751885AbWISRTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:19:41 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We keep getting requests from people that think that this might be
an exploitable hole where we would overwrite 4 bytes in the netdev
struct if the pci name would exceed 15 characters. In reality this
will never happen but we fix it anyway.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c             |    2 +-
 drivers/net/e1000/e1000_main.c |    2 +-
 drivers/net/ixgb/ixgb_main.c   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index d9750e2..ab0868c 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2572,7 +2572,7 @@ static int __devinit e100_probe(struct p
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e100_netpoll;
 #endif
-	strcpy(netdev->name, pci_name(pdev));
+	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
 	nic = netdev_priv(netdev);
 	nic->netdev = netdev;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 75de83e..dd01fdc 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -759,7 +759,7 @@ e1000_probe(struct pci_dev *pdev,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e1000_netpoll;
 #endif
-	strcpy(netdev->name, pci_name(pdev));
+	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
 	netdev->mem_start = mmio_start;
 	netdev->mem_end = mmio_start + mmio_len;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index ad604fe..949e5de 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -437,7 +437,7 @@ ixgb_probe(struct pci_dev *pdev,
 	netdev->poll_controller = ixgb_netpoll;
 #endif
 
-	strcpy(netdev->name, pci_name(pdev));
+	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 	netdev->mem_start = mmio_start;
 	netdev->mem_end = mmio_start + mmio_len;
 	netdev->base_addr = adapter->hw.io_base;



---
Auke Kok <auke-jan.h.kok@intel.com>
