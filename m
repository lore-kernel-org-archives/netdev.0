From: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] airo_cs: Remove typedef local_info_t
Date: Sat, 9 Aug 2014 22:16:23 +0530
Message-ID: <20140809164623.GA21522@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Linux kernel coding style guidelines suggest not using typedefs
for structure types. This patch gets rid of the typedef for
local_info_t. Also, the name of the struct is changed to drop the _t,
to make the name look less typedef-like.

The following Coccinelle semantic patch detects the case:

@tn@
identifier i;
type td;
@@

-typedef
 struct i { ... }
-td
 ;

@@
type tn.td;
identifier tn.i;
@@

-td
+ struct i

Signed-off-by: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
---
 drivers/net/wireless/airo_cs.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 7e9ede6..d9ed22b 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -56,18 +56,18 @@ static void airo_release(struct pcmcia_device *link);
 
 static void airo_detach(struct pcmcia_device *p_dev);
 
-typedef struct local_info_t {
+struct local_info {
 	struct net_device *eth_dev;
-} local_info_t;
+};
 
 static int airo_probe(struct pcmcia_device *p_dev)
 {
-	local_info_t *local;
+	struct local_info *local;
 
 	dev_dbg(&p_dev->dev, "airo_attach()\n");
 
 	/* Allocate space for private device-specific data */
-	local = kzalloc(sizeof(local_info_t), GFP_KERNEL);
+	local = kzalloc(sizeof(*local), GFP_KERNEL);
 	if (!local)
 		return -ENOMEM;
 
@@ -82,10 +82,11 @@ static void airo_detach(struct pcmcia_device *link)
 
 	airo_release(link);
 
-	if (((local_info_t *)link->priv)->eth_dev) {
-		stop_airo_card(((local_info_t *)link->priv)->eth_dev, 0);
+	if (((struct local_info *)link->priv)->eth_dev) {
+		stop_airo_card(((struct local_info *)link->priv)->eth_dev,
+			       0);
 	}
-	((local_info_t *)link->priv)->eth_dev = NULL;
+	((struct local_info *)link->priv)->eth_dev = NULL;
 
 	kfree(link->priv);
 } /* airo_detach */
@@ -101,7 +102,7 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev, void *priv_data)
 
 static int airo_config(struct pcmcia_device *link)
 {
-	local_info_t *dev;
+	struct local_info *dev;
 	int ret;
 
 	dev = link->priv;
@@ -121,10 +122,10 @@ static int airo_config(struct pcmcia_device *link)
 	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
-	((local_info_t *)link->priv)->eth_dev =
+	((struct local_info *)link->priv)->eth_dev =
 		init_airo_card(link->irq,
 			       link->resource[0]->start, 1, &link->dev);
-	if (!((local_info_t *)link->priv)->eth_dev)
+	if (!((struct local_info *)link->priv)->eth_dev)
 		goto failed;
 
 	return 0;
@@ -142,7 +143,7 @@ static void airo_release(struct pcmcia_device *link)
 
 static int airo_suspend(struct pcmcia_device *link)
 {
-	local_info_t *local = link->priv;
+	struct local_info *local = link->priv;
 
 	netif_device_detach(local->eth_dev);
 
@@ -151,7 +152,7 @@ static int airo_suspend(struct pcmcia_device *link)
 
 static int airo_resume(struct pcmcia_device *link)
 {
-	local_info_t *local = link->priv;
+	struct local_info *local = link->priv;
 
 	if (link->open) {
 		reset_airo_card(local->eth_dev);
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
