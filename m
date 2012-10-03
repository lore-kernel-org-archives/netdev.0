From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 15/20] drivers/net/ethernet/natsemi/xtsonic.c: fix error return code
Date: Wed,  3 Oct 2012 18:18:06 +0200
Message-ID: <1349281090-10013-16-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, mcuos.com@gmail.com,
	axel.lin@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
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
 drivers/net/ethernet/natsemi/xtsonic.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index e01c0a0..7dfe883 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -205,6 +205,7 @@ static int __init sonic_probe1(struct net_device *dev)
 	if (lp->descriptors == NULL) {
 		printk(KERN_ERR "%s: couldn't alloc DMA memory for "
 				" descriptors.\n", dev_name(lp->device));
+		err = -ENOMEM;
 		goto out;
 	}
 
