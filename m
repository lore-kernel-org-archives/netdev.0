From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/2] net: mvneta: remove bogus use of device_node.data ptr
Date: Thu, 20 Jul 2017 09:27:10 -0500
Message-ID: <20170720142711.12847-1-robh@kernel.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Nothing sets ever sets data, so it is always NULL. Remove it as this is
the only user of data ptr in the whole kernel, and it is going to be
removed from struct device_node.

Cc: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
Probably there's a better fix here to actually enable the h/w buffer 
manager.

I intend to take this thru the DT tree as patch 2 is dependent on this.

Rob

 drivers/net/ethernet/marvell/mvneta.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 0aab74c2a209..5624f4b49f9d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -4296,8 +4296,8 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	/* Obtain access to BM resources if enabled and already initialized */
 	bm_node = of_parse_phandle(dn, "buffer-manager", 0);
-	if (bm_node && bm_node->data) {
-		pp->bm_priv = bm_node->data;
+	if (bm_node) {
+		pp->bm_priv = NULL;
 		err = mvneta_bm_port_init(pdev, pp);
 		if (err < 0) {
 			dev_info(&pdev->dev, "use SW buffer management\n");
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
