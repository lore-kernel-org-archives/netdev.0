From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 02/11] net: usb: smsc95xx: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 16 Mar 2017 23:18:48 +0100
Message-ID: <1489702737-2401-3-git-send-email-tremyfr@gmail.com>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: oliver@neukum.org, jacmet@sunsite.dk,
        steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com,
        gregkh@linuxfoundation.org, davem@davemloft.net,
        robert.foss@collabora.com, allan@asix.com.tw, grundler@google.com,
        jarod@redhat.com, peter.chen@nxp.com, stefan.bruens@rwth-aachen.de,
        akpm@linux-foundation.org, adobriyan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/usb/smsc95xx.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 831aa33..4a8bf96 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -853,32 +853,32 @@ static void set_mdix_status(struct net_device *net, __u8 mdix_ctrl)
 	pdata->mdix_ctrl = mdix_ctrl;
 }
 
-static int smsc95xx_get_settings(struct net_device *net,
-				 struct ethtool_cmd *cmd)
+static int smsc95xx_get_link_ksettings(struct net_device *net,
+				       struct ethtool_link_ksettings *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	int retval;
 
-	retval = usbnet_get_settings(net, cmd);
+	retval = usbnet_get_link_ksettings(net, cmd);
 
-	cmd->eth_tp_mdix = pdata->mdix_ctrl;
-	cmd->eth_tp_mdix_ctrl = pdata->mdix_ctrl;
+	cmd->base.eth_tp_mdix = pdata->mdix_ctrl;
+	cmd->base.eth_tp_mdix_ctrl = pdata->mdix_ctrl;
 
 	return retval;
 }
 
-static int smsc95xx_set_settings(struct net_device *net,
-				 struct ethtool_cmd *cmd)
+static int smsc95xx_set_link_ksettings(struct net_device *net,
+				       const struct ethtool_link_ksettings *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	int retval;
 
-	if (pdata->mdix_ctrl != cmd->eth_tp_mdix_ctrl)
-		set_mdix_status(net, cmd->eth_tp_mdix_ctrl);
+	if (pdata->mdix_ctrl != cmd->base.eth_tp_mdix_ctrl)
+		set_mdix_status(net, cmd->base.eth_tp_mdix_ctrl);
 
-	retval = usbnet_set_settings(net, cmd);
+	retval = usbnet_set_link_ksettings(net, cmd);
 
 	return retval;
 }
@@ -889,8 +889,6 @@ static int smsc95xx_set_settings(struct net_device *net,
 	.get_drvinfo	= usbnet_get_drvinfo,
 	.get_msglevel	= usbnet_get_msglevel,
 	.set_msglevel	= usbnet_set_msglevel,
-	.get_settings	= smsc95xx_get_settings,
-	.set_settings	= smsc95xx_set_settings,
 	.get_eeprom_len	= smsc95xx_ethtool_get_eeprom_len,
 	.get_eeprom	= smsc95xx_ethtool_get_eeprom,
 	.set_eeprom	= smsc95xx_ethtool_set_eeprom,
@@ -898,6 +896,8 @@ static int smsc95xx_set_settings(struct net_device *net,
 	.get_regs	= smsc95xx_ethtool_getregs,
 	.get_wol	= smsc95xx_ethtool_get_wol,
 	.set_wol	= smsc95xx_ethtool_set_wol,
+	.get_link_ksettings	= smsc95xx_get_link_ksettings,
+	.set_link_ksettings	= smsc95xx_set_link_ksettings,
 };
 
 static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
