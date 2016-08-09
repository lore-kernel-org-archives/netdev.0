From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] net: dsa: b53: constify xfrm_replay structures
Date: Tue,  9 Aug 2016 18:58:09 +0200
Message-ID: <1470761889-26808-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The xfrm_replay structures are never modified, so declare them as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/dsa/b53/b53_common.c |    3 ++-
 drivers/net/dsa/b53/b53_mdio.c   |    2 +-
 drivers/net/dsa/b53/b53_mmap.c   |    2 +-
 drivers/net/dsa/b53/b53_priv.h   |    3 ++-
 drivers/net/dsa/b53/b53_spi.c    |    2 +-
 drivers/net/dsa/b53/b53_srab.c   |    2 +-
 6 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index bda37d3..38ee10d 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1681,7 +1681,8 @@ static int b53_switch_init(struct b53_device *dev)
 	return 0;
 }
 
-struct b53_device *b53_switch_alloc(struct device *base, struct b53_io_ops *ops,
+struct b53_device *b53_switch_alloc(struct device *base,
+				    const struct b53_io_ops *ops,
 				    void *priv)
 {
 	struct dsa_switch *ds;
diff --git a/drivers/net/dsa/b53/b53_mdio.c b/drivers/net/dsa/b53/b53_mdio.c
index aa87c3f..477a16b 100644
--- a/drivers/net/dsa/b53/b53_mdio.c
+++ b/drivers/net/dsa/b53/b53_mdio.c
@@ -267,7 +267,7 @@ static int b53_mdio_phy_write16(struct b53_device *dev, int addr, int reg,
 	return mdiobus_write_nested(bus, addr, reg, value);
 }
 
-static struct b53_io_ops b53_mdio_ops = {
+static const struct b53_io_ops b53_mdio_ops = {
 	.read8 = b53_mdio_read8,
 	.read16 = b53_mdio_read16,
 	.read32 = b53_mdio_read32,
diff --git a/drivers/net/dsa/b53/b53_mmap.c b/drivers/net/dsa/b53/b53_mmap.c
index 77ffc43..cc9e6bd 100644
--- a/drivers/net/dsa/b53/b53_mmap.c
+++ b/drivers/net/dsa/b53/b53_mmap.c
@@ -208,7 +208,7 @@ static int b53_mmap_write64(struct b53_device *dev, u8 page, u8 reg,
 	return 0;
 }
 
-static struct b53_io_ops b53_mmap_ops = {
+static const struct b53_io_ops b53_mmap_ops = {
 	.read8 = b53_mmap_read8,
 	.read16 = b53_mmap_read16,
 	.read32 = b53_mmap_read32,
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 835a744..d268493 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -182,7 +182,8 @@ static inline int is_cpu_port(struct b53_device *dev, int port)
 	return dev->cpu_port;
 }
 
-struct b53_device *b53_switch_alloc(struct device *base, struct b53_io_ops *ops,
+struct b53_device *b53_switch_alloc(struct device *base,
+				    const struct b53_io_ops *ops,
 				    void *priv);
 
 int b53_switch_detect(struct b53_device *dev);
diff --git a/drivers/net/dsa/b53/b53_spi.c b/drivers/net/dsa/b53/b53_spi.c
index 2bda0b5..1c847a1 100644
--- a/drivers/net/dsa/b53/b53_spi.c
+++ b/drivers/net/dsa/b53/b53_spi.c
@@ -270,7 +270,7 @@ static int b53_spi_write64(struct b53_device *dev, u8 page, u8 reg, u64 value)
 	return spi_write(spi, txbuf, sizeof(txbuf));
 }
 
-static struct b53_io_ops b53_spi_ops = {
+static const struct b53_io_ops b53_spi_ops = {
 	.read8 = b53_spi_read8,
 	.read16 = b53_spi_read16,
 	.read32 = b53_spi_read32,
diff --git a/drivers/net/dsa/b53/b53_srab.c b/drivers/net/dsa/b53/b53_srab.c
index 3e2d4a5..8a62b6a 100644
--- a/drivers/net/dsa/b53/b53_srab.c
+++ b/drivers/net/dsa/b53/b53_srab.c
@@ -344,7 +344,7 @@ err:
 	return ret;
 }
 
-static struct b53_io_ops b53_srab_ops = {
+static const struct b53_io_ops b53_srab_ops = {
 	.read8 = b53_srab_read8,
 	.read16 = b53_srab_read16,
 	.read32 = b53_srab_read32,
