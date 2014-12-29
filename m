From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 6/8] adm8211: fix error return code
Date: Mon, 29 Dec 2014 18:04:41 +0100
Message-ID: <1419872683-32709-7-git-send-email-Julia.Lawall@lip6.fr>
References: <1419872683-32709-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419872683-32709-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
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
 drivers/net/wireless/adm8211.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 17fcaab..f07a618 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1837,6 +1837,7 @@ static int adm8211_probe(struct pci_dev *pdev,
 	if (!priv->map) {
 		printk(KERN_ERR "%s (adm8211): Cannot map device memory\n",
 		       pci_name(pdev));
+		err = -ENOMEM;
 		goto err_free_dev;
 	}
 
