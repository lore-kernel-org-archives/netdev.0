From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 18/20] drivers/net/ethernet/sun/sungem.c: fix error return code
Date: Wed,  3 Oct 2012 18:18:03 +0200
Message-ID: <1349281090-10013-13-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, jdmason@kudzu.us,
	gerard.lledo@gmail.com, dhowells@redhat.com, joe@perches.com,
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
 drivers/net/ethernet/sun/sungem.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 9ae12d0..6c8695e 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2963,7 +2963,8 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}
 
-	if (gem_get_device_address(gp))
+	err = gem_get_device_address(gp);
+	if (err)
 		goto err_out_free_consistent;
 
 	dev->netdev_ops = &gem_netdev_ops;
