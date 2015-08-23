From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 03/11] net: davinci_emac: fix error return code
Date: Sun, 23 Aug 2015 02:11:14 +0200
Message-ID: <1440288682-12732-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1440288682-12732-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440288682-12732-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Propagate error code on failure.

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
 drivers/net/ethernet/ti/davinci_emac.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index aeebc0a..a21c77b 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -2004,8 +2004,10 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	if (res_ctrl) {
 		priv->ctrl_base =
 			devm_ioremap_resource(&pdev->dev, res_ctrl);
-		if (IS_ERR(priv->ctrl_base))
+		if (IS_ERR(priv->ctrl_base)) {
+			rc = PTR_ERR(priv->ctrl_base);
 			goto no_pdata;
+		}
 	} else {
 		priv->ctrl_base = priv->remap_addr + pdata->ctrl_mod_reg_offset;
 	}
