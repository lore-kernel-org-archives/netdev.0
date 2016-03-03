From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] asix: do not free array priv->mdio->irq
Date: Thu,  3 Mar 2016 13:27:56 +0000
Message-ID: <1457011676-19042-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Used to be allocated and required freeing, but now
priv->mdio->irq is now a fixed sized array and should no longer be
free'd.

Issue detected using static analysis with CoverityScan

Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/ax88172a.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index 224e7d8..cf77f2d 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -134,7 +134,6 @@ static void ax88172a_remove_mdio(struct usbnet *dev)
 
 	netdev_info(dev->net, "deregistering mdio bus %s\n", priv->mdio->id);
 	mdiobus_unregister(priv->mdio);
-	kfree(priv->mdio->irq);
 	mdiobus_free(priv->mdio);
 }
 
-- 
2.7.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
