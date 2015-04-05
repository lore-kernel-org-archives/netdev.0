From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/16] wan: lmc: fix error return code
Date: Sun,  5 Apr 2015 14:06:21 +0200
Message-ID: <1428235596-4757-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1428235596-4757-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1428235596-4757-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return a negative error code on failure.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret; expression e1,e2;
@@
(
if (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret = 0
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

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wan/lmc/lmc_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index bea0f31..317bc79 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -850,6 +850,7 @@ static int lmc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev = alloc_hdlcdev(sc);
 	if (!dev) {
 		printk(KERN_ERR "lmc:alloc_netdev for device failed\n");
+		err = -ENOMEM;
 		goto err_hdlcdev;
 	}
 

