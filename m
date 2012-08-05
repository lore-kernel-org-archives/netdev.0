From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 6/6] drivers/atm/iphase.c: fix error return code
Date: Sun,  5 Aug 2012 11:52:36 +0200
Message-ID: <1344160356-387-7-git-send-email-Julia.Lawall@lip6.fr>
References: <1344160356-387-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Julia Lawall <julia@diku.dk>
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344160356-387-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Convert a 0 error return code to a negative one, as returned elsewhere in the
function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret;
expression e,e1,e2,e3,e4,x;
@@

(
if (\(ret != 0\|ret < 0\) || ...) { ... return ...; }
|
ret = 0
)
... when != ret = e1
*x = \(kmalloc\|kzalloc\|kcalloc\|devm_kzalloc\|ioremap\|ioremap_nocache\|devm_ioremap\|devm_ioremap_nocache\)(...);
... when != x = e2
    when != ret = e3
*if (x == NULL || ...)
{
  ... when != ret = e4
*  return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/atm/iphase.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index d438601..96cce6d 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -2362,7 +2362,7 @@ static int __devinit ia_init(struct atm_dev *dev)
 	{  
 		printk(DEV_LABEL " (itf %d): can't set up page mapping\n",  
 			    dev->number);  
-		return error;  
+		return -ENOMEM;
 	}  
 	IF_INIT(printk(DEV_LABEL " (itf %d): rev.%d,base=%p,irq=%d\n",  
 			dev->number, iadev->pci->revision, base, iadev->irq);)
