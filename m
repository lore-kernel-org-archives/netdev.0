From: Levente Kurusa <levex@linux.com>
Subject: [PATCH 1/4] net: phy: call put_device on device_register() failure
Date: Fri, 13 Dec 2013 20:22:34 +0100
Message-ID: <1386962557-8899-2-git-send-email-levex@linux.com>
References: <1386962557-8899-1-git-send-email-levex@linux.com>
Cc: Levente Kurusa <levex@linux.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386962557-8899-1-git-send-email-levex@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is required to call put_device() if device_register() fails,
so that we give up the last reference to the device. Calling put_device
allows for mdiobus_release to be executed, kfreeing the bus.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Signed-off-by: Levente Kurusa <levex@linux.com>
---
 drivers/net/phy/mdio_bus.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 5617876..b071af7 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -154,6 +154,7 @@ int mdiobus_register(struct mii_bus *bus)
 	err = device_register(&bus->dev);
 	if (err) {
 		pr_err("mii_bus %s failed to register\n", bus->id);
+		put_device(&bus->dev);
 		return -EINVAL;
 	}
 
-- 
1.8.3.1
