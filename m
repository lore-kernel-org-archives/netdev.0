From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/1] net-PA Semi: Deletion of unnecessary checks before the
 function call "pci_dev_put"
Date: Sat, 29 Nov 2014 19:00:17 +0100
Message-ID: <547A09B1.9090102@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 29 Nov 2014 18:55:40 +0100

The pci_dev_put() function tests whether its argument is NULL
and then returns immediately. Thus the test around the call
is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/pasemi/pasemi_mac.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 30d934d..44e8d7d 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1837,10 +1837,8 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return err;
 
 out:
-	if (mac->iob_pdev)
-		pci_dev_put(mac->iob_pdev);
-	if (mac->dma_pdev)
-		pci_dev_put(mac->dma_pdev);
+	pci_dev_put(mac->iob_pdev);
+	pci_dev_put(mac->dma_pdev);
 
 	free_netdev(dev);
 out_disable_device:
-- 
2.1.3
