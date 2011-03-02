From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] mii: Convert printks to netdev_info
Date: Wed,  2 Mar 2011 09:18:11 -0800
Message-ID: <1b384ead46d062ba189b64649710a5625b7f6a2b.1299086044.git.joe@perches.com>
References: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4042 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756171Ab1CBRSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 12:18:13 -0500
Received: from Joe-Laptop.home (unknown [192.168.1.162])
	by mail.perches.com (Postfix) with ESMTP id 7753E2436B
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 09:18:04 -0800 (PST)
In-Reply-To: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a bit more data to the output.
Convert string speeds to integer.
Object size reduced a tiny bit.

$ size drivers/net/mii.o*
   text	   data	    bss	    dec	    hex	filename
   4155	     56	   1000	   5211	   145b	drivers/net/mii.o.new
   4184	     56	   1000	   5240	   1478	drivers/net/mii.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tun.c |   83 ++++++++++++++++++++--------------------------------
 1 files changed, 32 insertions(+), 51 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index f5e9ac0..55786a0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -34,8 +34,6 @@
  *    Modifications for 2.3.99-pre5 kernel.
  */
 
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
 #define DRV_NAME	"tun"
 #define DRV_VERSION	"1.6"
 #define DRV_DESCRIPTION	"Universal TUN/TAP device driver"
@@ -78,27 +76,11 @@
 #ifdef TUN_DEBUG
 static int debug;
 
-#define tun_debug(level, tun, fmt, args...)			\
-do {								\
-	if (tun->debug)						\
-		netdev_printk(level, tun->dev, fmt, ##args);	\
-} while (0)
-#define DBG1(level, fmt, args...)				\
-do {								\
-	if (debug == 2)						\
-		printk(level fmt, ##args);			\
-} while (0)
+#define DBG  if(tun->debug)printk
+#define DBG1 if(debug==2)printk
 #else
-#define tun_debug(level, tun, fmt, args...)			\
-do {								\
-	if (0)							\
-		netdev_printk(level, tun->dev, fmt, ##args);	\
-} while (0)
-#define DBG1(level, fmt, args...)				\
-do {								\
-	if (0)							\
-		printk(level fmt, ##args);			\
-} while (0)
+#define DBG( a... )
+#define DBG1( a... )
 #endif
 
 #define FLT_EXACT_COUNT 8
@@ -223,7 +205,7 @@ static void tun_put(struct tun_struct *tun)
 		tun_detach(tfile->tun);
 }
 
-/* TAP filtering */
+/* TAP filterting */
 static void addr_hash_set(u32 *mask, const u8 *addr)
 {
 	int n = ether_crc(ETH_ALEN, addr) >> 26;
@@ -378,7 +360,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
-	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
+	DBG(KERN_INFO "%s: tun_net_xmit %d\n", tun->dev->name, skb->len);
 
 	/* Drop packet if interface is not attached */
 	if (!tun->tfile)
@@ -517,7 +499,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 
 	sk = tun->socket.sk;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_poll\n");
+	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);
 
 	poll_wait(file, &tun->wq.wait, wait);
 
@@ -708,7 +690,7 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 	if (!tun)
 		return -EBADFD;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_write %ld\n", count);
+	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
 	result = tun_get_user(tun, iv, iov_length(iv, count),
 			      file->f_flags & O_NONBLOCK);
@@ -757,7 +739,7 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 			else if (sinfo->gso_type & SKB_GSO_UDP)
 				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
 			else {
-				pr_err("unexpected GSO type: "
+				printk(KERN_ERR "tun: unexpected GSO type: "
 				       "0x%x, gso_size %d, hdr_len %d\n",
 				       sinfo->gso_type, gso.gso_size,
 				       gso.hdr_len);
@@ -804,7 +786,7 @@ static ssize_t tun_do_read(struct tun_struct *tun,
 	struct sk_buff *skb;
 	ssize_t ret = 0;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_read\n");
+	DBG(KERN_INFO "%s: tun_chr_read\n", tun->dev->name);
 
 	add_wait_queue(&tun->wq.wait, &wait);
 	while (len) {
@@ -1101,7 +1083,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		if (device_create_file(&tun->dev->dev, &dev_attr_tun_flags) ||
 		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
 		    device_create_file(&tun->dev->dev, &dev_attr_group))
-			pr_err("Failed to create tun sysfs files\n");
+			printk(KERN_ERR "Failed to create tun sysfs files\n");
 
 		sk->sk_destruct = tun_sock_destruct;
 
@@ -1110,7 +1092,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			goto failed;
 	}
 
-	tun_debug(KERN_INFO, tun, "tun_set_iff\n");
+	DBG(KERN_INFO "%s: tun_set_iff\n", tun->dev->name);
 
 	if (ifr->ifr_flags & IFF_NO_PI)
 		tun->flags |= TUN_NO_PI;
@@ -1147,7 +1129,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 static int tun_get_iff(struct net *net, struct tun_struct *tun,
 		       struct ifreq *ifr)
 {
-	tun_debug(KERN_INFO, tun, "tun_get_iff\n");
+	DBG(KERN_INFO "%s: tun_get_iff\n", tun->dev->name);
 
 	strcpy(ifr->ifr_name, tun->dev->name);
 
@@ -1247,7 +1229,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	if (!tun)
 		goto unlock;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_ioctl cmd %d\n", cmd);
+	DBG(KERN_INFO "%s: tun_chr_ioctl cmd %d\n", tun->dev->name, cmd);
 
 	ret = 0;
 	switch (cmd) {
@@ -1267,8 +1249,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		else
 			tun->flags &= ~TUN_NOCHECKSUM;
 
-		tun_debug(KERN_INFO, tun, "checksum %s\n",
-			  arg ? "disabled" : "enabled");
+		DBG(KERN_INFO "%s: checksum %s\n",
+		    tun->dev->name, arg ? "disabled" : "enabled");
 		break;
 
 	case TUNSETPERSIST:
@@ -1278,34 +1260,33 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		else
 			tun->flags &= ~TUN_PERSIST;
 
-		tun_debug(KERN_INFO, tun, "persist %s\n",
-			  arg ? "enabled" : "disabled");
+		DBG(KERN_INFO "%s: persist %s\n",
+		    tun->dev->name, arg ? "enabled" : "disabled");
 		break;
 
 	case TUNSETOWNER:
 		/* Set owner of the device */
 		tun->owner = (uid_t) arg;
 
-		tun_debug(KERN_INFO, tun, "owner set to %d\n", tun->owner);
+		DBG(KERN_INFO "%s: owner set to %d\n", tun->dev->name, tun->owner);
 		break;
 
 	case TUNSETGROUP:
 		/* Set group of the device */
 		tun->group= (gid_t) arg;
 
-		tun_debug(KERN_INFO, tun, "group set to %d\n", tun->group);
+		DBG(KERN_INFO "%s: group set to %d\n", tun->dev->name, tun->group);
 		break;
 
 	case TUNSETLINK:
 		/* Only allow setting the type when the interface is down */
 		if (tun->dev->flags & IFF_UP) {
-			tun_debug(KERN_INFO, tun,
-				  "Linktype set failed because interface is up\n");
+			DBG(KERN_INFO "%s: Linktype set failed because interface is up\n",
+				tun->dev->name);
 			ret = -EBUSY;
 		} else {
 			tun->dev->type = (int) arg;
-			tun_debug(KERN_INFO, tun, "linktype set to %d\n",
-				  tun->dev->type);
+			DBG(KERN_INFO "%s: linktype set to %d\n", tun->dev->name, tun->dev->type);
 			ret = 0;
 		}
 		break;
@@ -1337,8 +1318,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 
 	case SIOCSIFHWADDR:
 		/* Set hw address */
-		tun_debug(KERN_DEBUG, tun, "set hw address: %pM\n",
-			  ifr.ifr_hwaddr.sa_data);
+		DBG(KERN_DEBUG "%s: set hw address: %pM\n",
+			tun->dev->name, ifr.ifr_hwaddr.sa_data);
 
 		ret = dev_set_mac_address(tun->dev, &ifr.ifr_hwaddr);
 		break;
@@ -1452,7 +1433,7 @@ static int tun_chr_fasync(int fd, struct file *file, int on)
 	if (!tun)
 		return -EBADFD;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_fasync %d\n", on);
+	DBG(KERN_INFO "%s: tun_chr_fasync %d\n", tun->dev->name, on);
 
 	if ((ret = fasync_helper(fd, file, on, &tun->fasync)) < 0)
 		goto out;
@@ -1474,7 +1455,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 {
 	struct tun_file *tfile;
 
-	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
+	DBG1(KERN_INFO "tunX: tun_chr_open\n");
 
 	tfile = kmalloc(sizeof(*tfile), GFP_KERNEL);
 	if (!tfile)
@@ -1495,7 +1476,7 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 	if (tun) {
 		struct net_device *dev = tun->dev;
 
-		tun_debug(KERN_INFO, tun, "tun_chr_close\n");
+		DBG(KERN_INFO "%s: tun_chr_close\n", dev->name);
 
 		__tun_detach(tun);
 
@@ -1626,18 +1607,18 @@ static int __init tun_init(void)
 {
 	int ret = 0;
 
-	pr_info("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
-	pr_info("%s\n", DRV_COPYRIGHT);
+	printk(KERN_INFO "tun: %s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
+	printk(KERN_INFO "tun: %s\n", DRV_COPYRIGHT);
 
 	ret = rtnl_link_register(&tun_link_ops);
 	if (ret) {
-		pr_err("Can't register link_ops\n");
+		printk(KERN_ERR "tun: Can't register link_ops\n");
 		goto err_linkops;
 	}
 
 	ret = misc_register(&tun_miscdev);
 	if (ret) {
-		pr_err("Can't register misc device %d\n", TUN_MINOR);
+		printk(KERN_ERR "tun: Can't register misc device %d\n", TUN_MINOR);
 		goto err_misc;
 	}
 	return  0;
-- 
1.7.4.2.g597a6.dirty

