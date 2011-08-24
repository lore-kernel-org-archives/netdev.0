From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] bna: unlock on error path in pnad_pci_probe()
Date: Wed, 24 Aug 2011 14:29:22 +0300
Message-ID: <20110824112922.GC5975@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Debashis Dutt <ddutt@brocade.com>,
	"open list:BROCADE BNA 10 GI..." <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41217 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395Ab1HXLbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 07:31:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We introduced a new lock here, so there was error path which needs
an unlock now.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index bdfda07..6ad4b47 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3167,7 +3167,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 	 */
 	err = bnad_pci_init(bnad, pdev, &using_dac);
 	if (err)
-		goto free_netdev;
+		goto unlock_mutex;
 
 	/*
 	 * Initialize bnad structure
@@ -3296,9 +3296,9 @@ drv_uninit:
 	bnad_uninit(bnad);
 pci_uninit:
 	bnad_pci_uninit(pdev);
+unlock_mutex:
 	mutex_unlock(&bnad->conf_mutex);
 	bnad_lock_uninit(bnad);
-free_netdev:
 	free_netdev(netdev);
 	return err;
 }
