From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 2/2] strip: use of netdev_priv
Date: Mon, 14 Feb 2005 00:32:43 +0100
Message-ID: <20050213233243.GD2898@electric-eye.fr.zoreil.com>
References: <420FBAD3.3020909@pobox.com> <20050213233059.GC2060@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050213233059.GC2060@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use of netdev_priv.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/wireless/strip.c~strip-010 drivers/net/wireless/strip.c
--- a/drivers/net/wireless/strip.c~strip-010	2005-02-14 00:11:08.527937733 +0100
+++ b/drivers/net/wireless/strip.c	2005-02-14 00:11:08.532936920 +0100
@@ -876,7 +876,7 @@ static int allocate_buffers(struct strip
  */
 static int strip_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct strip *strip_info = dev->priv;
+	struct strip *strip_info = netdev_priv(dev);
 	int old_mtu = strip_info->mtu;
 	unsigned char *orbuff = strip_info->rx_buff;
 	unsigned char *osbuff = strip_info->sx_buff;
@@ -1563,7 +1563,7 @@ static void strip_send(struct strip *str
 /* Encapsulate a datagram and kick it into a TTY queue. */
 static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "%s: xmit call when iface is down\n",
@@ -1639,7 +1639,7 @@ static int strip_header(struct sk_buff *
 			unsigned short type, void *daddr, void *saddr,
 			unsigned len)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 	STRIP_Header *header = (STRIP_Header *) skb_push(skb, sizeof(STRIP_Header));
 
 	/*printk(KERN_INFO "%s: strip_header 0x%04X %s\n", dev->name, type,
@@ -1648,7 +1648,7 @@ static int strip_header(struct sk_buff *
 	header->src_addr = strip_info->true_dev_addr;
 	header->protocol = htons(type);
 
-	/*HexDump("strip_header", (struct strip *)(dev->priv), skb->data, skb->data + skb->len); */
+	/*HexDump("strip_header", netdev_priv(dev), skb->data, skb->data + skb->len); */
 
 	if (!daddr)
 		return (-dev->hard_header_len);
@@ -2400,7 +2400,7 @@ static int set_mac_address(struct strip 
 
 static int strip_set_mac_address(struct net_device *dev, void *addr)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 	struct sockaddr *sa = addr;
 
 	printk(KERN_INFO "%s: strip_set_dev_mac_address called\n", dev->name);
@@ -2410,8 +2410,8 @@ static int strip_set_mac_address(struct 
 
 static struct net_device_stats *strip_get_stats(struct net_device *dev)
 {
+	struct strip *strip_info = netdev_priv(dev);
 	static struct net_device_stats stats;
-	struct strip *strip_info = (struct strip *) (dev->priv);
 
 	memset(&stats, 0, sizeof(struct net_device_stats));
 
@@ -2455,7 +2455,7 @@ static struct net_device_stats *strip_ge
 
 static int strip_open_low(struct net_device *dev)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 
 	if (strip_info->tty == NULL)
 		return (-ENODEV);
@@ -2488,7 +2488,7 @@ static int strip_open_low(struct net_dev
 
 static int strip_close_low(struct net_device *dev)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 
 	if (strip_info->tty == NULL)
 		return -EBUSY;

_
