From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/6] e100: Fix iomap mem accesses
Date: Fri, 01 Feb 2008 08:21:34 -0800
Message-ID: <20080201162134.29347.349.stgit@localhost.localdomain>
References: <20080201162118.29347.13268.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24278 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755650AbYBAQV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:21:58 -0500
In-Reply-To: <20080201162118.29347.13268.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>

writeX functions are not permitted on iomap-ped space change to iowriteX,
also pci_unmap pci_map-ped space on exit (instead of iounmap).

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 51cf577..9d42dd8 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1958,7 +1958,7 @@ static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
 
 	if(restart_required) {
 		// ack the rnr?
-		writeb(stat_ack_rnr, &nic->csr->scb.stat_ack);
+		iowrite8(stat_ack_rnr, &nic->csr->scb.stat_ack);
 		e100_start_receiver(nic, nic->rx_to_clean);
 		if(work_done)
 			(*work_done)++;
@@ -2774,7 +2774,7 @@ static void __devexit e100_remove(struct pci_dev *pdev)
 		struct nic *nic = netdev_priv(netdev);
 		unregister_netdev(netdev);
 		e100_free(nic);
-		iounmap(nic->csr);
+		pci_iounmap(pdev, nic->csr);
 		free_netdev(netdev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);

