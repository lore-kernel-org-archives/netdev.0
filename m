From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 5/20] drivers/net/ethernet/sis/sis900.c: fix error return code
Date: Wed,  3 Oct 2012 18:17:55 +0200
Message-ID: <1349281090-10013-5-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: venza@brownhat.org
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
 drivers/net/ethernet/sis/sis900.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 203d9c6..fb9f6b3 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -478,8 +478,10 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 
 	/* IO region. */
 	ioaddr = pci_iomap(pci_dev, 0, 0);
-	if (!ioaddr)
+	if (!ioaddr) {
+		ret = -ENOMEM;
 		goto err_out_cleardev;
+	}
 
 	sis_priv = netdev_priv(net_dev);
 	sis_priv->ioaddr = ioaddr;
