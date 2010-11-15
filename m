From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/10] drivers/isdn/i4l: Remove unnecessary casts of netdev_priv
Date: Mon, 15 Nov 2010 13:12:24 -0800
Message-ID: <d653560dec1888cb09d6166a9be3a9b3eeb1cfc9.1289855436.git.joe@perches.com>
References: <cover.1289855436.git.joe@perches.com>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289855436.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/isdn/i4l/isdn_concap.c |    2 +-
 drivers/isdn/i4l/isdn_net.c    |   20 ++++++++++----------
 drivers/isdn/i4l/isdn_ppp.c    |   12 ++++++------
 3 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_concap.c b/drivers/isdn/i4l/isdn_concap.c
index 46048e5..d568689 100644
--- a/drivers/isdn/i4l/isdn_concap.c
+++ b/drivers/isdn/i4l/isdn_concap.c
@@ -61,7 +61,7 @@ static int isdn_concap_dl_data_req(struct concap_proto *concap, struct sk_buff *
 static int isdn_concap_dl_connect_req(struct concap_proto *concap)
 {
 	struct net_device *ndev = concap -> net_dev;
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(ndev);
+	isdn_net_local *lp = netdev_priv(ndev);
 	int ret;
 	IX25DEBUG( "isdn_concap_dl_connect_req: %s \n", ndev -> name);
 
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 26d44c3..afeede7 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -827,7 +827,7 @@ isdn_net_dial(void)
 void
 isdn_net_hangup(struct net_device *d)
 {
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(d);
+	isdn_net_local *lp = netdev_priv(d);
 	isdn_ctrl cmd;
 #ifdef CONFIG_ISDN_X25
 	struct concap_proto *cprot = lp->netdev->cprot;
@@ -1052,7 +1052,7 @@ isdn_net_xmit(struct net_device *ndev, struct sk_buff *skb)
 {
 	isdn_net_dev *nd;
 	isdn_net_local *slp;
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(ndev);
+	isdn_net_local *lp = netdev_priv(ndev);
 	int retv = NETDEV_TX_OK;
 
 	if (((isdn_net_local *) netdev_priv(ndev))->master) {
@@ -1116,7 +1116,7 @@ isdn_net_xmit(struct net_device *ndev, struct sk_buff *skb)
 static void
 isdn_net_adjust_hdr(struct sk_buff *skb, struct net_device *dev)
 {
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(dev);
+	isdn_net_local *lp = netdev_priv(dev);
 	if (!skb)
 		return;
 	if (lp->p_encap == ISDN_NET_ENCAP_ETHER) {
@@ -1131,7 +1131,7 @@ isdn_net_adjust_hdr(struct sk_buff *skb, struct net_device *dev)
 
 static void isdn_net_tx_timeout(struct net_device * ndev)
 {
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(ndev);
+	isdn_net_local *lp = netdev_priv(ndev);
 
 	printk(KERN_WARNING "isdn_tx_timeout dev %s dialstate %d\n", ndev->name, lp->dialstate);
 	if (!lp->dialstate){
@@ -1165,7 +1165,7 @@ static void isdn_net_tx_timeout(struct net_device * ndev)
 static netdev_tx_t
 isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(ndev);
+	isdn_net_local *lp = netdev_priv(ndev);
 #ifdef CONFIG_ISDN_X25
 	struct concap_proto * cprot = lp -> netdev -> cprot;
 /* At this point hard_start_xmit() passes control to the encapsulation
@@ -1347,7 +1347,7 @@ isdn_net_close(struct net_device *dev)
 static struct net_device_stats *
 isdn_net_get_stats(struct net_device *dev)
 {
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(dev);
+	isdn_net_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -1426,7 +1426,7 @@ isdn_net_ciscohdlck_alloc_skb(isdn_net_local *lp, int len)
 static int
 isdn_ciscohdlck_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(dev);
+	isdn_net_local *lp = netdev_priv(dev);
 	unsigned long len = 0;
 	unsigned long expires = 0;
 	int tmp = 0;
@@ -1493,7 +1493,7 @@ isdn_ciscohdlck_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static int isdn_net_ioctl(struct net_device *dev,
 			  struct ifreq *ifr, int cmd)
 {
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(dev);
+	isdn_net_local *lp = netdev_priv(dev);
 
 	switch (lp->p_encap) {
 #ifdef CONFIG_ISDN_PPP
@@ -1786,7 +1786,7 @@ isdn_net_ciscohdlck_receive(isdn_net_local *lp, struct sk_buff *skb)
 static void
 isdn_net_receive(struct net_device *ndev, struct sk_buff *skb)
 {
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(ndev);
+	isdn_net_local *lp = netdev_priv(ndev);
 	isdn_net_local *olp = lp;	/* original 'lp' */
 #ifdef CONFIG_ISDN_X25
 	struct concap_proto *cprot = lp -> netdev -> cprot;
@@ -1800,7 +1800,7 @@ isdn_net_receive(struct net_device *ndev, struct sk_buff *skb)
 		 * handle master's statistics and hangup-timeout
 		 */
 		ndev = lp->master;
-		lp = (isdn_net_local *) netdev_priv(ndev);
+		lp = netdev_priv(ndev);
 		lp->stats.rx_packets++;
 		lp->stats.rx_bytes += skb->len;
 	}
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index fe824e0..97c5cc2 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1221,7 +1221,7 @@ isdn_ppp_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct ippp_struct *ipt,*ipts;
 	int slot, retval = NETDEV_TX_OK;
 
-	mlp = (isdn_net_local *) netdev_priv(netdev);
+	mlp = netdev_priv(netdev);
 	nd = mlp->netdev;       /* get master lp */
 
 	slot = mlp->ppp_slot;
@@ -1985,7 +1985,7 @@ isdn_ppp_dev_ioctl_stats(int slot, struct ifreq *ifr, struct net_device *dev)
 {
 	struct ppp_stats __user *res = ifr->ifr_data;
 	struct ppp_stats t;
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(dev);
+	isdn_net_local *lp = netdev_priv(dev);
 
 	if (!access_ok(VERIFY_WRITE, res, sizeof(struct ppp_stats)))
 		return -EFAULT;
@@ -2024,7 +2024,7 @@ isdn_ppp_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int error=0;
 	int len;
-	isdn_net_local *lp = (isdn_net_local *) netdev_priv(dev);
+	isdn_net_local *lp = netdev_priv(dev);
 
 
 	if (lp->p_encap != ISDN_NET_ENCAP_SYNCPPP)
@@ -2091,7 +2091,7 @@ isdn_ppp_dial_slave(char *name)
 
 	sdev = lp->slave;
 	while (sdev) {
-		isdn_net_local *mlp = (isdn_net_local *) netdev_priv(sdev);
+		isdn_net_local *mlp = netdev_priv(sdev);
 		if (!(mlp->flags & ISDN_NET_CONNECTED))
 			break;
 		sdev = mlp->slave;
@@ -2099,7 +2099,7 @@ isdn_ppp_dial_slave(char *name)
 	if (!sdev)
 		return 2;
 
-	isdn_net_dial_req((isdn_net_local *) netdev_priv(sdev));
+	isdn_net_dial_req(netdev_priv(sdev));
 	return 0;
 #else
 	return -1;
@@ -2122,7 +2122,7 @@ isdn_ppp_hangup_slave(char *name)
 
 	sdev = lp->slave;
 	while (sdev) {
-		isdn_net_local *mlp = (isdn_net_local *) netdev_priv(sdev);
+		isdn_net_local *mlp = netdev_priv(sdev);
 
 		if (mlp->slave) { /* find last connected link in chain */
 			isdn_net_local *nlp = ISDN_SLAVE_PRIV(mlp);
-- 
1.7.3.1.g432b3.dirty
