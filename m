From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 13/20 V2] drivers/net/ethernet/amd/amd8111e.c: fix error return code
Date: Sat,  6 Oct 2012 00:10:51 +0200
Message-ID: <1349475053-11464-3-git-send-email-peter.senna@gmail.com>
References: <1349475053-11464-1-git-send-email-peter.senna@gmail.com>
Cc: joe@perches.com, dhowells@redhat.com, rick.jones2@hp.com,
	netdev@pradeepdalvi.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349475053-11464-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>

The function amd8111e_probe_one() return 0 for success and negative
value for most of its internal tests failures. There are two exceptions
that are error cases going to err_free_reg:. For this two cases, the
function abort its success execution path, but returns non negative
value, making it dificult for a caller function to notice the error.

This patch fixes the error cases that do not return negative values.

This was found by Coccinelle, but the code change was made by hand.
This patch is not robot generated.

A simplified version of the semantic match that finds this problem is
as follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
Change from V1:
        Updated commit message. See:
        http://www.kernelhub.org/?p=2&msg=139319

 drivers/net/ethernet/amd/amd8111e.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 64d0d9c..3491d43 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1845,6 +1845,7 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 	if((pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM))==0){
 		printk(KERN_ERR "amd8111e: No Power Management capability, "
 		       "exiting.\n");
+		err = -ENODEV;
 		goto err_free_reg;
 	}
 
@@ -1852,6 +1853,7 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) < 0) {
 		printk(KERN_ERR "amd8111e: DMA not supported,"
 			"exiting.\n");
+		err = -ENODEV;
 		goto err_free_reg;
 	}
 
