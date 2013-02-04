From: Joe Perches <joe@perches.com>
Subject: [PATCH 8/8] drivers:net:misc: Remove unnecessary alloc/OOM messages
Date: Sun,  3 Feb 2013 19:28:15 -0800
Message-ID: <a729555c8acf2cc3ef4c80531757b37a948c4e55.1359939013.git.joe@perches.com>
References: <cover.1359939012.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	linux-hams@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1359939012.git.joe@perches.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

alloc failures already get standardized OOM
messages and a dump_stack.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/hamradio/dmascc.c | 7 +------
 drivers/net/phy/spi_ks8995.c  | 4 +---
 drivers/net/virtio_net.c      | 4 +---
 3 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index ce555d9..6636022 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -463,13 +463,8 @@ static int __init setup_adapter(int card_base, int type, int n)
 
 	/* Initialize what is necessary for write_scc and write_scc_data */
 	info = kzalloc(sizeof(struct scc_info), GFP_KERNEL | GFP_DMA);
-	if (!info) {
-		printk(KERN_ERR "dmascc: "
-		       "could not allocate memory for %s at %#3x\n",
-		       hw[type].name, card_base);
+	if (!info)
 		goto out;
-	}
-
 
 	info->dev[0] = alloc_netdev(0, "", dev_setup);
 	if (!info->dev[0]) {
diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 41eb8ff..5c87eef 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -275,10 +275,8 @@ static int ks8995_probe(struct spi_device *spi)
 	pdata = spi->dev.platform_data;
 
 	ks = kzalloc(sizeof(*ks), GFP_KERNEL);
-	if (!ks) {
-		dev_err(&spi->dev, "no memory for private data\n");
+	if (!ks)
 		return -ENOMEM;
-	}
 
 	mutex_init(&ks->lock);
 	ks->pdata = pdata;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index eda2042..381a2d8 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -976,10 +976,8 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	buf = kzalloc(((uc_count + mc_count) * ETH_ALEN) +
 		      (2 * sizeof(mac_data->entries)), GFP_ATOMIC);
 	mac_data = buf;
-	if (!buf) {
-		dev_warn(&dev->dev, "No memory for MAC address buffer\n");
+	if (!buf)
 		return;
-	}
 
 	sg_init_table(sg, 2);
 
-- 
1.8.0.dirty
