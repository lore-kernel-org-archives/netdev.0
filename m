From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 1/2] net: replace random_ether_addr() with
	eth_hw_addr_random()
Date: Wed, 15 Feb 2012 17:45:39 +0100
Message-ID: <1329324340-13461-2-git-send-email-danny.kukawka@bisect.de>
References: <1329324340-13461-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Daniele Venzano <venza@brownhat.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Danny Kukawka <dkukawka@suse.de>, linux-kernel@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>, Roger Luethi <rl@hellgate.ch>,
	Hartley Sweeten <hsweeten@visionengravers.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>,
	virtualization@lists.linux-foundation.org,
	Florian Fainelli <florian@openwrt.org>, Krzysztof Halasa <khc@pm.waw.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1329324340-13461-1-git-send-email-danny.kukawka@bisect.de>
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

Replace usage of random_ether_addr() with eth_hw_addr_random()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Change the trivial cases.

v2: adapt to renamed eth_hw_addr_random()

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/cadence/macb.c               |    2 +-
 drivers/net/ethernet/cirrus/ep93xx_eth.c          |    2 +-
 drivers/net/ethernet/davicom/dm9000.c             |    2 +-
 drivers/net/ethernet/dnet.c                       |    2 +-
 drivers/net/ethernet/faraday/ftgmac100.c          |    2 +-
 drivers/net/ethernet/faraday/ftmac100.c           |    2 +-
 drivers/net/ethernet/mipsnet.c                    |    2 +-
 drivers/net/ethernet/natsemi/macsonic.c           |    2 +-
 drivers/net/ethernet/rdc/r6040.c                  |    2 +-
 drivers/net/ethernet/sis/sis900.c                 |    2 +-
 drivers/net/ethernet/smsc/smsc9420.c              |    5 ++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 drivers/net/ethernet/toshiba/tc35815.c            |    2 +-
 drivers/net/ethernet/via/via-rhine.c              |    2 +-
 drivers/net/ifb.c                                 |    2 +-
 drivers/net/tun.c                                 |    2 +-
 drivers/net/usb/smsc75xx.c                        |    2 +-
 drivers/net/usb/smsc95xx.c                        |    2 +-
 drivers/net/veth.c                                |    4 ++--
 drivers/net/virtio_net.c                          |    2 +-
 drivers/net/wan/hdlc_fr.c                         |    2 +-
 drivers/net/wan/hdlc_raw_eth.c                    |    2 +-
 net/ipv4/ip_gre.c                                 |    2 +-
 net/l2tp/l2tp_eth.c                               |    2 +-
 24 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 2320068..0206c54 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -87,7 +87,7 @@ static void __init macb_get_hwaddr(struct macb *bp)
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
 	} else {
 		netdev_info(bp->dev, "invalid hw address, using random\n");
-		random_ether_addr(bp->dev->dev_addr);
+		eth_hw_addr_random(bp->dev);
 	}
 }
 
diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 4317af8..3c02b88 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -859,7 +859,7 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 	ep->mdc_divisor = 40;	/* Max HCLK 100 MHz, min MDIO clk 2.5 MHz.  */
 
 	if (is_zero_ether_addr(dev->dev_addr))
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 
 	err = register_netdev(dev);
 	if (err) {
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index f801754..8400179 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1587,7 +1587,7 @@ dm9000_probe(struct platform_device *pdev)
 		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
 			 "set using ifconfig\n", ndev->name);
 
-		random_ether_addr(ndev->dev_addr);
+		eth_hw_addr_random(ndev);
 		mac_src = "random";
 	}
 
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 925c9ba..051758b 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -897,7 +897,7 @@ static int __devinit dnet_probe(struct platform_device *pdev)
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		/* choose a random ethernet address */
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 		__dnet_set_hwaddr(bp);
 	}
 
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 47f85c3..16b0704 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1289,7 +1289,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	netdev_info(netdev, "irq %d, mapped at %p\n", priv->irq, priv->base);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		random_ether_addr(netdev->dev_addr);
+		eth_hw_addr_random(netdev);
 		netdev_info(netdev, "generated random MAC address %pM\n",
 			    netdev->dev_addr);
 	}
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index bb336a0..829b109 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -1133,7 +1133,7 @@ static int ftmac100_probe(struct platform_device *pdev)
 	netdev_info(netdev, "irq %d, mapped at %p\n", priv->irq, priv->base);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		random_ether_addr(netdev->dev_addr);
+		eth_hw_addr_random(netdev);
 		netdev_info(netdev, "generated random MAC address %pM\n",
 			    netdev->dev_addr);
 	}
diff --git a/drivers/net/ethernet/mipsnet.c b/drivers/net/ethernet/mipsnet.c
index d05b0c9..771ce9b 100644
--- a/drivers/net/ethernet/mipsnet.c
+++ b/drivers/net/ethernet/mipsnet.c
@@ -281,7 +281,7 @@ static int __devinit mipsnet_probe(struct platform_device *dev)
 	 * Lacking any better mechanism to allocate a MAC address we use a
 	 * random one ...
 	 */
-	random_ether_addr(netdev->dev_addr);
+	eth_hw_addr_random(netdev);
 
 	err = register_netdev(netdev);
 	if (err) {
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index f1b8556..e640e23 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -307,7 +307,7 @@ static void __devinit mac_onboard_sonic_ethernet_addr(struct net_device *dev)
 
 	printk(KERN_WARNING "macsonic: MAC address in CAM entry 15 "
 	                    "seems invalid, will use a random MAC\n");
-	random_ether_addr(dev->dev_addr);
+	eth_hw_addr_random(dev);
 }
 
 static int __devinit mac_onboard_sonic_probe(struct net_device *dev)
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index cb0eca8..6ba3ff4 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1152,7 +1152,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	if (!(adrp[0] || adrp[1] || adrp[2])) {
 		netdev_warn(dev, "MAC address not initialized, "
 					"generating random\n");
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 	}
 
 	/* Link new device into r6040_root_dev */
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index c8efc70..79e6c37 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -527,7 +527,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
 
 	if (!ret || !is_valid_ether_addr(net_dev->dev_addr)) {
-		random_ether_addr(net_dev->dev_addr);
+		eth_hw_addr_random(net_dev);
 		printk(KERN_WARNING "%s: Unreadable or invalid MAC address,"
 				"using random generated one\n", dev_name);
 	}
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index a9efbdf..8cc47ad 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -509,10 +509,9 @@ static void smsc9420_check_mac_address(struct net_device *dev)
 			smsc_dbg(PROBE, "Mac Address is read from EEPROM");
 		} else {
 			/* eeprom values are invalid, generate random MAC */
-			random_ether_addr(dev->dev_addr);
+			eth_hw_addr_random(dev);
 			smsc9420_set_mac_address(dev);
-			smsc_dbg(PROBE,
-				"MAC Address is set to random_ether_addr");
+			smsc_dbg(PROBE, "MAC Address is set to random");
 		}
 	}
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 96fa2da..a361ee9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -910,7 +910,7 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 					     priv->dev->base_addr,
 					     priv->dev->dev_addr, 0);
 		if  (!is_valid_ether_addr(priv->dev->dev_addr))
-			random_ether_addr(priv->dev->dev_addr);
+			eth_hw_addr_random(priv->dev);
 	}
 	pr_warning("%s: device MAC address %pM\n", priv->dev->name,
 						   priv->dev->dev_addr);
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 71b785c..4754f00 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -850,7 +850,7 @@ static int __devinit tc35815_init_one(struct pci_dev *pdev,
 	/* Retrieve the ethernet address. */
 	if (tc35815_init_dev_addr(dev)) {
 		dev_warn(&pdev->dev, "not valid ether addr\n");
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 	}
 
 	rc = register_netdev(dev);
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 10b18eb..ccd5921 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -984,7 +984,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		/* Report it and use a random ethernet address instead */
 		netdev_err(dev, "Invalid MAC address: %pM\n", dev->dev_addr);
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 		netdev_info(dev, "Using random MAC address: %pM\n",
 			    dev->dev_addr);
 	}
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index e05b645..344dceb 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -184,7 +184,7 @@ static void ifb_setup(struct net_device *dev)
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
 	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
-	random_ether_addr(dev->dev_addr);
+	eth_hw_addr_random(dev);
 }
 
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 93c5d72..2c5d349 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -531,7 +531,7 @@ static void tun_net_init(struct net_device *dev)
 		ether_setup(dev);
 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 
 		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 3b017bb..187d01c 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -615,7 +615,7 @@ static void smsc75xx_init_mac_address(struct usbnet *dev)
 	}
 
 	/* no eeprom, or eeprom values are invalid. generate random MAC */
-	random_ether_addr(dev->net->dev_addr);
+	eth_hw_addr_random(dev->net);
 	netif_dbg(dev, ifup, dev->net, "MAC address set to random_ether_addr");
 }
 
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index d45520e..5f19f84 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -614,7 +614,7 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
 	}
 
 	/* no eeprom, or eeprom values are invalid. generate random MAC */
-	random_ether_addr(dev->net->dev_addr);
+	eth_hw_addr_random(dev->net);
 	netif_dbg(dev, ifup, dev->net, "MAC address set to random_ether_addr\n");
 }
 
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 49f4667..b8a697f 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -346,7 +346,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	}
 
 	if (tbp[IFLA_ADDRESS] == NULL)
-		random_ether_addr(peer->dev_addr);
+		eth_hw_addr_random(peer);
 
 	err = register_netdevice(peer);
 	put_net(net);
@@ -368,7 +368,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	 */
 
 	if (tb[IFLA_ADDRESS] == NULL)
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 
 	if (tb[IFLA_IFNAME])
 		nla_strlcpy(dev->name, tb[IFLA_IFNAME], IFNAMSIZ);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4880aa8..bc2cb11 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1061,7 +1061,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_config_val_len(vdev, VIRTIO_NET_F_MAC,
 				  offsetof(struct virtio_net_config, mac),
 				  dev->dev_addr, dev->addr_len) < 0)
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index eb20281..7c6cb4f3 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1087,7 +1087,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	}
 
 	if (type == ARPHRD_ETHER)
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 	else {
 		*(__be16*)dev->dev_addr = htons(dlci);
 		dlci_to_q922(dev->broadcast, dlci);
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index 05c9b0b..3ab72b3 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -101,7 +101,7 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr)
 		old_qlen = dev->tx_queue_len;
 		ether_setup(dev);
 		dev->tx_queue_len = old_qlen;
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 		netif_dormant_off(dev);
 		return 0;
 	}
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6b3ca5b..9b1fb61 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1529,7 +1529,7 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nla
 		return -EEXIST;
 
 	if (dev->type == ARPHRD_ETHER && !tb[IFLA_ADDRESS])
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 
 	mtu = ipgre_tunnel_bind_dev(dev);
 	if (!tb[IFLA_MTU])
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index d2726a7..63fe5f3 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -64,7 +64,7 @@ static int l2tp_eth_dev_init(struct net_device *dev)
 	struct l2tp_eth *priv = netdev_priv(dev);
 
 	priv->dev = dev;
-	random_ether_addr(dev->dev_addr);
+	eth_hw_addr_random(dev);
 	memset(&dev->broadcast[0], 0xff, 6);
 
 	return 0;
-- 
1.7.8.3
