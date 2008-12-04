From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next] um: Kill directly reference of netdev->priv
Date: Thu, 04 Dec 2008 20:56:32 +0800
Message-ID: <4937D380.80104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61611 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756596AbYLDM4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 07:56:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply replace netdev->priv with netdev_priv().

Not do compile test, because no such arch.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 arch/um/drivers/daemon_kern.c            |    2 +-
 arch/um/drivers/mcast_kern.c             |    2 +-
 arch/um/drivers/net_kern.c               |   22 +++++++++++-----------
 arch/um/drivers/pcap_kern.c              |    2 +-
 arch/um/drivers/slip_kern.c              |    2 +-
 arch/um/drivers/slirp_kern.c             |    2 +-
 arch/um/drivers/vde_kern.c               |    2 +-
 arch/um/os-Linux/drivers/ethertap_kern.c |    2 +-
 arch/um/os-Linux/drivers/tuntap_kern.c   |    2 +-
 9 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/arch/um/drivers/daemon_kern.c b/arch/um/drivers/daemon_kern.c
index d53ff52..b4a1522 100644
--- a/arch/um/drivers/daemon_kern.c
+++ b/arch/um/drivers/daemon_kern.c
@@ -22,7 +22,7 @@ static void daemon_init(struct net_device *dev, void *data)
 	struct daemon_data *dpri;
 	struct daemon_init *init = data;
 
-	pri = dev->priv;
+	pri = netdev_priv(dev);
 	dpri = (struct daemon_data *) pri->user;
 	dpri->sock_type = init->sock_type;
 	dpri->ctl_sock = init->ctl_sock;
diff --git a/arch/um/drivers/mcast_kern.c b/arch/um/drivers/mcast_kern.c
index 8c4378a..ffc6416 100644
--- a/arch/um/drivers/mcast_kern.c
+++ b/arch/um/drivers/mcast_kern.c
@@ -28,7 +28,7 @@ static void mcast_init(struct net_device *dev, void *data)
 	struct mcast_data *dpri;
 	struct mcast_init *init = data;
 
-	pri = dev->priv;
+	pri = netdev_priv(dev);
 	dpri = (struct mcast_data *) pri->user;
 	dpri->addr = init->addr;
 	dpri->port = init->port;
diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 74f1a17..fde510b 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -76,7 +76,7 @@ out:
 
 static int uml_net_rx(struct net_device *dev)
 {
-	struct uml_net_private *lp = dev->priv;
+	struct uml_net_private *lp = netdev_priv(dev);
 	int pkt_len;
 	struct sk_buff *skb;
 
@@ -119,7 +119,7 @@ static void uml_dev_close(struct work_struct *work)
 static irqreturn_t uml_net_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	struct uml_net_private *lp = dev->priv;
+	struct uml_net_private *lp = netdev_priv(dev);
 	int err;
 
 	if (!netif_running(dev))
@@ -150,7 +150,7 @@ out:
 
 static int uml_net_open(struct net_device *dev)
 {
-	struct uml_net_private *lp = dev->priv;
+	struct uml_net_private *lp = netdev_priv(dev);
 	int err;
 
 	if (lp->fd >= 0) {
@@ -195,7 +195,7 @@ out:
 
 static int uml_net_close(struct net_device *dev)
 {
-	struct uml_net_private *lp = dev->priv;
+	struct uml_net_private *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -213,7 +213,7 @@ static int uml_net_close(struct net_device *dev)
 
 static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct uml_net_private *lp = dev->priv;
+	struct uml_net_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int len;
 
@@ -250,7 +250,7 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *uml_net_get_stats(struct net_device *dev)
 {
-	struct uml_net_private *lp = dev->priv;
+	struct uml_net_private *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -267,7 +267,7 @@ static void uml_net_tx_timeout(struct net_device *dev)
 
 static int uml_net_set_mac(struct net_device *dev, void *addr)
 {
-	struct uml_net_private *lp = dev->priv;
+	struct uml_net_private *lp = netdev_priv(dev);
 	struct sockaddr *hwaddr = addr;
 
 	spin_lock_irq(&lp->lock);
@@ -368,7 +368,7 @@ static void net_device_release(struct device *dev)
 {
 	struct uml_net *device = dev->driver_data;
 	struct net_device *netdev = device->dev;
-	struct uml_net_private *lp = netdev->priv;
+	struct uml_net_private *lp = netdev_priv(netdev);
 
 	if (lp->remove != NULL)
 		(*lp->remove)(&lp->user);
@@ -420,7 +420,7 @@ static void eth_configure(int n, void *init, char *mac,
 
 	printk(KERN_INFO "Netdevice %d (%pM) : ", n, device->mac);
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	/* This points to the transport private data. It's still clear, but we
 	 * must memset it to 0 *now*. Let's help the drivers. */
 	memset(lp, 0, size);
@@ -730,7 +730,7 @@ static int net_remove(int n, char **error_out)
 		return -ENODEV;
 
 	dev = device->dev;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	if (lp->fd > 0)
 		return -EBUSY;
 	unregister_netdev(dev);
@@ -761,7 +761,7 @@ static int uml_inetaddr_event(struct notifier_block *this, unsigned long event,
 	if (dev->open != uml_net_open)
 		return NOTIFY_DONE;
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	proc = NULL;
 	switch (event) {
diff --git a/arch/um/drivers/pcap_kern.c b/arch/um/drivers/pcap_kern.c
index 3a750dd..2860525 100644
--- a/arch/um/drivers/pcap_kern.c
+++ b/arch/um/drivers/pcap_kern.c
@@ -21,7 +21,7 @@ void pcap_init(struct net_device *dev, void *data)
 	struct pcap_data *ppri;
 	struct pcap_init *init = data;
 
-	pri = dev->priv;
+	pri = netdev_priv(dev);
 	ppri = (struct pcap_data *) pri->user;
 	ppri->host_if = init->host_if;
 	ppri->promisc = init->promisc;
diff --git a/arch/um/drivers/slip_kern.c b/arch/um/drivers/slip_kern.c
index d19faec..5ec1756 100644
--- a/arch/um/drivers/slip_kern.c
+++ b/arch/um/drivers/slip_kern.c
@@ -19,7 +19,7 @@ static void slip_init(struct net_device *dev, void *data)
 	struct slip_data *spri;
 	struct slip_init *init = data;
 
-	private = dev->priv;
+	private = netdev_priv(dev);
 	spri = (struct slip_data *) private->user;
 
 	memset(spri->name, 0, sizeof(spri->name));
diff --git a/arch/um/drivers/slirp_kern.c b/arch/um/drivers/slirp_kern.c
index d987af2..f15a6e7 100644
--- a/arch/um/drivers/slirp_kern.c
+++ b/arch/um/drivers/slirp_kern.c
@@ -22,7 +22,7 @@ void slirp_init(struct net_device *dev, void *data)
 	struct slirp_init *init = data;
 	int i;
 
-	private = dev->priv;
+	private = netdev_priv(dev);
 	spri = (struct slirp_data *) private->user;
 
 	spri->argw = init->argw;
diff --git a/arch/um/drivers/vde_kern.c b/arch/um/drivers/vde_kern.c
index add7e72..1b852bf 100644
--- a/arch/um/drivers/vde_kern.c
+++ b/arch/um/drivers/vde_kern.c
@@ -19,7 +19,7 @@ static void vde_init(struct net_device *dev, void *data)
 	struct uml_net_private *pri;
 	struct vde_data *vpri;
 
-	pri = dev->priv;
+	pri = netdev_priv(dev);
 	vpri = (struct vde_data *) pri->user;
 
 	vpri->vde_switch = init->vde_switch;
diff --git a/arch/um/os-Linux/drivers/ethertap_kern.c b/arch/um/os-Linux/drivers/ethertap_kern.c
index 046a131..7f6f9a7 100644
--- a/arch/um/os-Linux/drivers/ethertap_kern.c
+++ b/arch/um/os-Linux/drivers/ethertap_kern.c
@@ -22,7 +22,7 @@ static void etap_init(struct net_device *dev, void *data)
 	struct ethertap_data *epri;
 	struct ethertap_init *init = data;
 
-	pri = dev->priv;
+	pri = netdev_priv(dev);
 	epri = (struct ethertap_data *) pri->user;
 	epri->dev_name = init->dev_name;
 	epri->gate_addr = init->gate_addr;
diff --git a/arch/um/os-Linux/drivers/tuntap_kern.c b/arch/um/os-Linux/drivers/tuntap_kern.c
index 6b9e33d..4048800 100644
--- a/arch/um/os-Linux/drivers/tuntap_kern.c
+++ b/arch/um/os-Linux/drivers/tuntap_kern.c
@@ -21,7 +21,7 @@ static void tuntap_init(struct net_device *dev, void *data)
 	struct tuntap_data *tpri;
 	struct tuntap_init *init = data;
 
-	pri = dev->priv;
+	pri = netdev_priv(dev);
 	tpri = (struct tuntap_data *) pri->user;
 	tpri->dev_name = init->dev_name;
 	tpri->fixed_config = (init->dev_name != NULL);
-- 
1.5.3.4


