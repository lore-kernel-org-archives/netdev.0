From: Kumar Gala <galak@kernel.crashing.org>
Subject: modpost warning question
Date: Wed, 25 Jul 2007 02:14:12 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0707250210520.14366@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: sam@ravnborg.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

I'm seeing the following warning:

WARNING: vmlinux.o(.init.text+0x1acdc): Section mismatch: reference to
.exit.text:gfar_mdio_exit (between 'gfar_init' and 'gfar_mdio_init')

I don't understand why its not ok to access .exit.text from .init.text

The following addresses the issue, however I don't particularly like it:

diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index ac3596f..100bf41 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -245,7 +245,7 @@ int __init gfar_mdio_init(void)
 	return driver_register(&gianfar_mdio_driver);
 }

-void __exit gfar_mdio_exit(void)
+void gfar_mdio_exit(void)
 {
 	driver_unregister(&gianfar_mdio_driver);
 }
diff --git a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
index 5d34004..b373091 100644
--- a/drivers/net/gianfar_mii.h
+++ b/drivers/net/gianfar_mii.h
@@ -42,5 +42,5 @@ struct gfar_mii {
 int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
 int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
 int __init gfar_mdio_init(void);
-void __exit gfar_mdio_exit(void);
+void gfar_mdio_exit(void);
 #endif /* GIANFAR_PHY_H */
