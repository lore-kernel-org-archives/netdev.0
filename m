From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/7] [sk98lin]: Use netif_carrier_* instead of IFF_RUNNING and remove obsolete usage of IFF_RUNNING
Date: Mon, 28 Mar 2005 02:10:12 +0200
Message-ID: <20050328001012.GT3086@postel.suug.ch>
References: <20050328000610.GN3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, mlindner@syskonnect.de, rroesler@syskonnect.de
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328000610.GN3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/28 00:18:49+02:00 tgraf@suug.ch 
#   [sk98lin]: Use netif_carrier_* instead of IFF_RUNNING and remove obsolete usage of IFF_RUNNING
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
# 
# drivers/net/sk98lin/skge.c
#   2005/03/28 00:18:37+02:00 tgraf@suug.ch +3 -5
#   [sk98lin]: Use netif_carrier_* instead of IFF_RUNNING and remove obsolete usage of IFF_RUNNING
# 
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2005-03-28 01:07:40 +02:00
+++ b/drivers/net/sk98lin/skge.c	2005-03-28 01:07:40 +02:00
@@ -4212,7 +4212,7 @@
 			Flags);
 
 		SkGeStopPort(pAC, IoC, FromPort, SK_STOP_ALL, SK_HARD_RST);
-		pAC->dev[Param.Para32[0]]->flags &= ~IFF_RUNNING;
+		netif_carrier_off(pAC->dev[Param.Para32[0]]);
 		spin_unlock_irqrestore(
 			&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 			Flags);
@@ -4355,7 +4355,7 @@
 		}
 
 		/* Inform the world that link protocol is up. */
-		pAC->dev[Param.Para32[0]]->flags |= IFF_RUNNING;
+		netif_carrier_on(pAC->dev[Param.Para32[0]]);
 
 		break;
 	case SK_DRV_NET_DOWN:	 /* SK_U32 Reason */
@@ -4368,7 +4368,7 @@
 		} else {
 			DoPrintInterfaceChange = SK_TRUE;
 		}
-		pAC->dev[Param.Para32[1]]->flags &= ~IFF_RUNNING;
+		netif_carrier_off(pAC->dev[Param.Para32[1]]);
 		break;
 	case SK_DRV_SWITCH_HARD: /* SK_U32 FromPortIdx SK_U32 ToPortIdx */
 		SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_EVENT,
@@ -4961,7 +4961,6 @@
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller =	&SkGePollController;
 #endif
-	dev->flags &= 		~IFF_RUNNING;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	SET_ETHTOOL_OPS(dev, &SkGeEthtoolOps);
 
@@ -5035,7 +5034,6 @@
 		dev->set_mac_address    = &SkGeSetMacAddr;
 		dev->do_ioctl           = &SkGeIoctl;
 		dev->change_mtu         = &SkGeChangeMtu;
-		dev->flags             &= ~IFF_RUNNING;
 		SET_NETDEV_DEV(dev, &pdev->dev);
 		SET_ETHTOOL_OPS(dev, &SkGeEthtoolOps);
 
