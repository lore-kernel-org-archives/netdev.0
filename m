From: Kumar Gala <galak@freescale.com>
Subject: [PATCH] initialize a spin lock in gianfar driver
Date: Fri, 4 Mar 2005 23:12:59 -0600 (CST)
Message-ID: <Pine.LNX.4.61.0503042305570.23572@blarg.somerset.sps.mot.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jaka@activetools.si, linux-kernel@vger.kernel.org,
        linuxppc-embedded@ozlabs.org, netdev@oss.sgi.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Initialize the mdio_lock spin lock in mii_info struct, which is otherwise 
accessed prior to initialization.

Signed-off-by: Jaka Mocnik <jaka@activetools.si>
Signed-off-by: Kumar Gala <kumar.gala@freescale.com>

---

diff -Nru a/drivers/net/gianfar.c b/drivers/net/gianfar.c
--- a/drivers/net/gianfar.c	2005-03-04 23:03:27 -06:00
+++ b/drivers/net/gianfar.c	2005-03-04 23:03:27 -06:00
@@ -377,6 +377,8 @@
 			ADVERTISED_1000baseT_Full);
 	mii_info->autoneg = 1;
 
+	spin_lock_init(&mii_info->mdio_lock);
+
 	mii_info->mii_id = priv->einfo->phyid;
 
 	mii_info->dev = dev;
