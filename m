From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] kill ->accept_fastpath hook
Date: Wed, 09 Mar 2005 13:47:52 -0500
Message-ID: <422F44D8.3010009@pobox.com>
References: <20050309092628.3c9014db@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070304060109090902000902"
Cc: Stephen Hemminger <shemminger@osdl.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
In-Reply-To: <20050309092628.3c9014db@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070304060109090902000902
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> Trivial reordering of netdevice structure to save four bytes.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

If we are twiddling struct net_device, might as well kill this hook. 
Never called AFAICS, and only assigned -- to a no-op stub -- in one driver.

Signed-off-by: Jeff Garzik <jgarzik@pobox.com>


--------------070304060109090902000902
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

===== include/linux/netdevice.h 1.99 vs edited =====
--- 1.99/include/linux/netdevice.h	2005-02-11 00:54:25 -05:00
+++ edited/include/linux/netdevice.h	2005-03-09 13:26:25 -05:00
@@ -469,7 +469,6 @@
 	int			(*hard_header_parse)(struct sk_buff *skb,
 						     unsigned char *haddr);
 	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
-	int			(*accept_fastpath)(struct net_device *, struct dst_entry*);
 #ifdef CONFIG_NETPOLL
 	int			netpoll_rx;
 #endif
===== net/bridge/br_device.c 1.17 vs edited =====
--- 1.17/net/bridge/br_device.c	2004-07-29 17:40:51 -04:00
+++ edited/net/bridge/br_device.c	2005-03-09 13:26:08 -05:00
@@ -83,11 +83,6 @@
 	return 0;
 }
 
-static int br_dev_accept_fastpath(struct net_device *dev, struct dst_entry *dst)
-{
-	return -1;
-}
-
 void br_dev_setup(struct net_device *dev)
 {
 	memset(dev->dev_addr, 0, ETH_ALEN);
@@ -103,7 +98,6 @@
 	dev->destructor = free_netdev;
 	SET_MODULE_OWNER(dev);
 	dev->stop = br_dev_stop;
-	dev->accept_fastpath = br_dev_accept_fastpath;
 	dev->tx_queue_len = 0;
 	dev->set_mac_address = NULL;
 	dev->priv_flags = IFF_EBRIDGE;

--------------070304060109090902000902--
