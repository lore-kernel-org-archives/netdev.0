From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 02/11] mdio_bus: convert bus code to use dev_groups
Date: Sun,  6 Oct 2013 23:55:41 -0700
Message-ID: <1381128950-28125-3-git-send-email-gregkh@linuxfoundation.org>
References: <1381128950-28125-1-git-send-email-gregkh@linuxfoundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Nick Bowler <nbowler@elliptictech.com>,
	<netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381128950-28125-1-git-send-email-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dev_attrs field of struct bus_type is going away soon, dev_groups
should be used instead.  This converts the MDIO bus code to use the
correct field.

Cc: David S. Miller <davem@davemloft.net>
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Nick Bowler <nbowler@elliptictech.com>
Cc: <netdev@vger.kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

David, I can take this through my driver-core tree if you like, just let
me know what would be the easiest for you.

 drivers/net/phy/mdio_bus.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index dc92097..5617876 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -438,17 +438,19 @@ phy_id_show(struct device *dev, struct device_attribute *attr, char *buf)
 
 	return sprintf(buf, "0x%.8lx\n", (unsigned long)phydev->phy_id);
 }
+static DEVICE_ATTR_RO(phy_id);
 
-static struct device_attribute mdio_dev_attrs[] = {
-	__ATTR_RO(phy_id),
-	__ATTR_NULL
+static struct attribute *mdio_dev_attrs[] = {
+	&dev_attr_phy_id.attr,
+	NULL,
 };
+ATTRIBUTE_GROUPS(mdio_dev);
 
 struct bus_type mdio_bus_type = {
 	.name		= "mdio_bus",
 	.match		= mdio_bus_match,
 	.pm		= MDIO_BUS_PM_OPS,
-	.dev_attrs	= mdio_dev_attrs,
+	.dev_groups	= mdio_dev_groups,
 };
 EXPORT_SYMBOL(mdio_bus_type);
 
-- 
1.8.4.6.g82e253f.dirty
