From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 17/20] drivers/net/ethernet/sun/niu.c: fix error return code
Date: Wed,  3 Oct 2012 18:18:04 +0200
Message-ID: <1349281090-10013-14-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, mcarlson@broadcom.com,
	eric.dumazet@gmail.com, mchan@broadcom.com, shuah.khan@hp.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

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
 drivers/net/ethernet/sun/niu.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 8419bf3..275b430 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9788,6 +9788,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 
 	if (!pci_is_pcie(pdev)) {
 		dev_err(&pdev->dev, "Cannot find PCI Express capability, aborting\n");
+		err = -ENODEV;
 		goto err_out_free_res;
 	}
 
