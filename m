From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: [PATCH resend] drivers/net: use printk_once
Date: Sun, 23 Aug 2009 20:26:56 +0200
Message-ID: <4A9189F0.1000506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933729AbZHWS07@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: drivers/net: use printk_once

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
Acked-by: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 9ed4a15..18e9e4f 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -151,15 +151,11 @@ static void mlx4_en_remove(struct mlx4_dev *dev, void *endev_ptr)
 
 static void *mlx4_en_add(struct mlx4_dev *dev)
 {
-	static int mlx4_en_version_printed;
 	struct mlx4_en_dev *mdev;
 	int i;
 	int err;
 
-	if (!mlx4_en_version_printed) {
-		printk(KERN_INFO "%s", mlx4_en_version);
-		mlx4_en_version_printed++;
-	}
+	printk_once(KERN_INFO "%s", mlx4_en_version);
 
 	mdev = kzalloc(sizeof *mdev, GFP_KERNEL);
 	if (!mdev) {
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 0f32db3..dbb1d9c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2622,14 +2622,12 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
-	static int mv643xx_eth_version_printed;
 	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 	struct mv643xx_eth_shared_private *msp;
 	struct resource *res;
 	int ret;
 
-	if (!mv643xx_eth_version_printed++)
-		printk(KERN_NOTICE "MV-643xx 10/100/1000 ethernet "
+	printk_once(KERN_NOTICE "MV-643xx 10/100/1000 ethernet "
 			"driver version %s\n", mv643xx_eth_driver_version);
 
 	ret = -EINVAL;
