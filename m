From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Mon, 6 Aug 2007 16:16:49 -0400
Message-ID: <20070806201649.GK6442@tuxdriver.com>
References: <20070806201441.GJ6442@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070806201441.GJ6442-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These are intended for 2.6.24...

---

The following changes since commit fdc8f43b5e49b64b251bb48da95193a13ac0132f:
  Michael Buesch (1):
        softmac: Fix deadlock of wx_set_essid with assoc work

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik

Bill Nottingham (1):
      remove gratuitous space in airo module description

Faidon Liambotis (2):
      Kconfig: order options
      Kconfig: remove references of pcmcia-cs

Mariusz Kozlowski (1):
      drivers/net/wireless/prism54/oid_mgt.c: kmalloc + memset conversion to kzalloc

Matthias Kaehlcke (1):
      Use mutex instead of semaphore in the Host AP driver

Ulrich Kunitz (1):
      zd1211rw: monitor all packets

Yoann Padioleau (1):
      dev->priv to netdev_priv(dev), for drivers/net/wireless

 drivers/net/wireless/Kconfig               |   85 +++++++++++----------------
 drivers/net/wireless/airo.c                |    4 +-
 drivers/net/wireless/arlan-proc.c          |   14 ++--
 drivers/net/wireless/hostap/hostap_cs.c    |    2 +-
 drivers/net/wireless/hostap/hostap_hw.c    |   16 +++---
 drivers/net/wireless/hostap/hostap_ioctl.c |   14 ++--
 drivers/net/wireless/hostap/hostap_wlan.h  |    3 +-
 drivers/net/wireless/orinoco_tmd.c         |    2 +-
 drivers/net/wireless/prism54/isl_ioctl.c   |    6 +-
 drivers/net/wireless/prism54/oid_mgt.c     |    4 +-
 drivers/net/wireless/ray_cs.c              |   66 +++++++++++-----------
 drivers/net/wireless/strip.c               |    2 +-
 drivers/net/wireless/wl3501_cs.c           |   66 +++++++++++-----------
 drivers/net/wireless/zd1211rw/zd_chip.h    |    5 --
 drivers/net/wireless/zd1211rw/zd_mac.c     |   44 ++++++++++++--
 15 files changed, 172 insertions(+), 161 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index ae27af0..80667b1 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -63,11 +63,6 @@ config WAVELAN
 	  a Radio LAN (wireless Ethernet-like Local Area Network) using the
 	  radio frequencies 900 MHz and 2.4 GHz.
 
-	  This driver support the ISA version of the WaveLAN card.  A separate
-	  driver for the PCMCIA (PC-card) hardware is available in David
-	  Hinds' pcmcia-cs package (see the file <file:Documentation/Changes>
-	  for location).
-
 	  If you want to use an ISA WaveLAN card under Linux, say Y and read
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>. Some more specific
@@ -379,30 +374,6 @@ config PCI_HERMES
 	  common.  Some of the built-in wireless adaptors in laptops are of
 	  this variety.
 
-config ATMEL
-      tristate "Atmel at76c50x chipset  802.11b support"
-      depends on (PCI || PCMCIA) && WLAN_80211
-      select WIRELESS_EXT
-      select FW_LOADER
-      select CRC32
-       ---help---
-        A driver 802.11b wireless cards based on the Atmel fast-vnet
-        chips. This driver supports standard Linux wireless extensions. 
- 
-        Many  cards based on this chipset do not have flash memory
-        and need their firmware loaded at start-up. If yours is 
-        one of these, you will need to provide a firmware image
-        to be loaded into the card by the driver. The Atmel
-        firmware package can be downloaded from
-        <http://www.thekelleys.org.uk/atmel>
-
-config PCI_ATMEL
-      tristate "Atmel at76c506 PCI cards"
-      depends on ATMEL && PCI
-       ---help---
-        Enable support for PCI and mini-PCI cards containing the
-        Atmel at76c506 chip.
-
 config PCMCIA_HERMES
 	tristate "Hermes PCMCIA card support"
 	depends on PCMCIA && HERMES
@@ -414,12 +385,7 @@ config PCMCIA_HERMES
 	  such as the Linksys, D-Link and Farallon Skyline.  It should also
 	  work on Symbol cards such as the 3Com AirConnect and Ericsson WLAN.
 
-	  To use your PC-cards, you will need supporting software from David
-	  Hinds' pcmcia-cs package (see the file <file:Documentation/Changes>
-	  for location).  You also want to check out the PCMCIA-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  You will also very likely also need the Wireless Tools in order to
+	  You will very likely need the Wireless Tools in order to
 	  configure your card and that /etc/pcmcia/wireless.opts works:
 	  <http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html>.
 
@@ -437,6 +403,40 @@ config PCMCIA_SPECTRUM
 	  for downloading Symbol firmware are available at
 	  <http://sourceforge.net/projects/orinoco/>
 
+config ATMEL
+      tristate "Atmel at76c50x chipset  802.11b support"
+      depends on (PCI || PCMCIA) && WLAN_80211
+      select WIRELESS_EXT
+      select FW_LOADER
+      select CRC32
+       ---help---
+        A driver 802.11b wireless cards based on the Atmel fast-vnet
+        chips. This driver supports standard Linux wireless extensions.
+
+        Many  cards based on this chipset do not have flash memory
+        and need their firmware loaded at start-up. If yours is
+        one of these, you will need to provide a firmware image
+        to be loaded into the card by the driver. The Atmel
+        firmware package can be downloaded from
+        <http://www.thekelleys.org.uk/atmel>
+
+config PCI_ATMEL
+      tristate "Atmel at76c506 PCI cards"
+      depends on ATMEL && PCI
+       ---help---
+        Enable support for PCI and mini-PCI cards containing the
+        Atmel at76c506 chip.
+
+config PCMCIA_ATMEL
+	tristate "Atmel at76c502/at76c504 PCMCIA cards"
+	depends on ATMEL && PCMCIA
+	select WIRELESS_EXT
+	select FW_LOADER
+	select CRC32
+	---help---
+	  Enable support for PCMCIA cards containing the
+	  Atmel at76c502 and at76c504 chips.
+
 config AIRO_CS
 	tristate "Cisco/Aironet 34X/35X/4500/4800 PCMCIA cards"
 	depends on PCMCIA && (BROKEN || !M32R) && WLAN_80211
@@ -457,21 +457,6 @@ config AIRO_CS
 	  and Cisco proprietary API, so both the Linux Wireless Tools and the
 	  Cisco Linux utilities can be used to configure the card.
 
-	  To use your PC-cards, you will need supporting software from David
-	  Hinds' pcmcia-cs package (see the file <file:Documentation/Changes>
-	  for location).  You also want to check out the PCMCIA-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-config PCMCIA_ATMEL
-	tristate "Atmel at76c502/at76c504 PCMCIA cards"
-	depends on ATMEL && PCMCIA
-	select WIRELESS_EXT
-	select FW_LOADER
-	select CRC32
-	---help---
-	  Enable support for PCMCIA cards containing the
-	  Atmel at76c502 and at76c504 chips.
-
 config PCMCIA_WL3501
       tristate "Planet WL3501 PCMCIA cards"
       depends on EXPERIMENTAL && PCMCIA && WLAN_80211
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index ee1cc14..a152797 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -241,8 +241,8 @@ static int proc_perm = 0644;
 
 MODULE_AUTHOR("Benjamin Reed");
 MODULE_DESCRIPTION("Support for Cisco/Aironet 802.11 wireless ethernet \
-                   cards.  Direct support for ISA/PCI/MPI cards and support \
-		   for PCMCIA when used with airo_cs.");
+cards.  Direct support for ISA/PCI/MPI cards and support \
+for PCMCIA when used with airo_cs.");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_SUPPORTED_DEVICE("Aironet 4500, 4800 and Cisco 340/350");
 module_param_array(io, int, NULL, 0);
diff --git a/drivers/net/wireless/arlan-proc.c b/drivers/net/wireless/arlan-proc.c
index 015abd9..c6e70db 100644
--- a/drivers/net/wireless/arlan-proc.c
+++ b/drivers/net/wireless/arlan-proc.c
@@ -435,7 +435,7 @@ static int arlan_sysctl_info(ctl_table * ctl, int write, struct file *filp,
 		goto final;
 	}
 	else
-		priva = arlan_device[devnum]->priv;
+		priva = netdev_priv(arlan_device[devnum]);
 
 	if (priva == NULL)
 	{
@@ -654,7 +654,7 @@ static int arlan_sysctl_info161719(ctl_table * ctl, int write, struct file *filp
 		goto final;
 	}
 	else
-		priva = arlan_device[devnum]->priv;
+		priva = netdev_priv(arlan_device[devnum]);
 	if (priva == NULL)
 	{
 		printk(KERN_WARNING " Could not find the device private in arlan procsys, bad\n ");
@@ -688,7 +688,7 @@ static int arlan_sysctl_infotxRing(ctl_table * ctl, int write, struct file *filp
 		  goto final;
 	}
 	else
-		priva = arlan_device[devnum]->priv;
+		priva = netdev_priv(arlan_device[devnum]);
 	if (priva == NULL)
 	{
 		printk(KERN_WARNING " Could not find the device private in arlan procsys, bad\n ");
@@ -716,7 +716,7 @@ static int arlan_sysctl_inforxRing(ctl_table * ctl, int write, struct file *filp
 		  pos += sprintf(arlan_drive_info + pos, "No device found here \n");
 		  goto final;
 	} else
-		priva = arlan_device[devnum]->priv;
+		priva = netdev_priv(arlan_device[devnum]);
 	if (priva == NULL)
 	{
 		printk(KERN_WARNING " Could not find the device private in arlan procsys, bad\n ");
@@ -745,7 +745,7 @@ static int arlan_sysctl_info18(ctl_table * ctl, int write, struct file *filp,
 		goto final;
 	}
 	else
-		priva = arlan_device[devnum]->priv;
+		priva = netdev_priv(arlan_device[devnum]);
 	if (priva == NULL)
 	{
 		printk(KERN_WARNING " Could not find the device private in arlan procsys, bad\n ");
@@ -780,7 +780,7 @@ static int arlan_configure(ctl_table * ctl, int write, struct file *filp,
 	}
 	else if (arlan_device[devnum] != NULL)
 	{
-		  priv = arlan_device[devnum]->priv;
+		  priv = netdev_priv(arlan_device[devnum]);
 
 		  arlan_command(arlan_device[devnum], ARLAN_COMMAND_CLEAN_AND_CONF);
 	}
@@ -805,7 +805,7 @@ static int arlan_sysctl_reset(ctl_table * ctl, int write, struct file *filp,
 	}
 	else if (arlan_device[devnum] != NULL)
 	{
-		priv = arlan_device[devnum]->priv;
+		priv = netdev_priv(arlan_device[devnum]);
 		arlan_command(arlan_device[devnum], ARLAN_COMMAND_CLEAN_AND_RESET);
 
 	} else
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 30e723f..f9cf22b 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -272,7 +272,7 @@ static int sandisk_enable_wireless(struct net_device *dev)
 {
 	int res, ret = 0;
 	conf_reg_t reg;
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	tuple_t tuple;
 	cisparse_t *parse = NULL;
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index 959887b..adedb97 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -825,7 +825,7 @@ static int hfa384x_get_rid(struct net_device *dev, u16 rid, void *buf, int len,
 	    local->hw_downloading)
 		return -ENODEV;
 
-	res = down_interruptible(&local->rid_bap_sem);
+	res = mutex_lock_interruptible(&local->rid_bap_mtx);
 	if (res)
 		return res;
 
@@ -834,7 +834,7 @@ static int hfa384x_get_rid(struct net_device *dev, u16 rid, void *buf, int len,
 		printk(KERN_DEBUG "%s: hfa384x_get_rid: CMDCODE_ACCESS failed "
 		       "(res=%d, rid=%04x, len=%d)\n",
 		       dev->name, res, rid, len);
-		up(&local->rid_bap_sem);
+		mutex_unlock(&local->rid_bap_mtx);
 		return res;
 	}
 
@@ -861,7 +861,7 @@ static int hfa384x_get_rid(struct net_device *dev, u16 rid, void *buf, int len,
 		res = hfa384x_from_bap(dev, BAP0, buf, len);
 
 	spin_unlock_bh(&local->baplock);
-	up(&local->rid_bap_sem);
+	mutex_unlock(&local->rid_bap_mtx);
 
 	if (res) {
 		if (res != -ENODATA)
@@ -902,7 +902,7 @@ static int hfa384x_set_rid(struct net_device *dev, u16 rid, void *buf, int len)
 	/* RID len in words and +1 for rec.rid */
 	rec.len = cpu_to_le16(len / 2 + len % 2 + 1);
 
-	res = down_interruptible(&local->rid_bap_sem);
+	res = mutex_lock_interruptible(&local->rid_bap_mtx);
 	if (res)
 		return res;
 
@@ -917,12 +917,12 @@ static int hfa384x_set_rid(struct net_device *dev, u16 rid, void *buf, int len)
 	if (res) {
 		printk(KERN_DEBUG "%s: hfa384x_set_rid (rid=%04x, len=%d) - "
 		       "failed - res=%d\n", dev->name, rid, len, res);
-		up(&local->rid_bap_sem);
+		mutex_unlock(&local->rid_bap_mtx);
 		return res;
 	}
 
 	res = hfa384x_cmd(dev, HFA384X_CMDCODE_ACCESS_WRITE, rid, NULL, NULL);
-	up(&local->rid_bap_sem);
+	mutex_unlock(&local->rid_bap_mtx);
 
 	if (res) {
 		printk(KERN_DEBUG "%s: hfa384x_set_rid: CMDCODE_ACCESS_WRITE "
@@ -3171,7 +3171,7 @@ prism2_init_local_data(struct prism2_helper_functions *funcs, int card_idx,
 	spin_lock_init(&local->cmdlock);
 	spin_lock_init(&local->baplock);
 	spin_lock_init(&local->lock);
-	init_MUTEX(&local->rid_bap_sem);
+	mutex_init(&local->rid_bap_mtx);
 
 	if (card_idx < 0 || card_idx >= MAX_PARM_DEVICES)
 		card_idx = 0;
@@ -3424,7 +3424,7 @@ static void prism2_suspend(struct net_device *dev)
 	struct local_info *local;
 	union iwreq_data wrqu;
 
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 	local = iface->local;
 
 	/* Send disconnect event, e.g., to trigger reassociation after resume
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 8c71077..d58ac84 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -3088,7 +3088,7 @@ static int prism2_ioctl_priv_download(local_info_t *local, struct iw_point *p)
 static int prism2_set_genericelement(struct net_device *dev, u8 *elem,
 				     size_t len)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	u8 *buf;
 
@@ -3116,7 +3116,7 @@ static int prism2_ioctl_siwauth(struct net_device *dev,
 				struct iw_request_info *info,
 				struct iw_param *data, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 
 	switch (data->flags & IW_AUTH_INDEX) {
@@ -3182,7 +3182,7 @@ static int prism2_ioctl_giwauth(struct net_device *dev,
 				struct iw_request_info *info,
 				struct iw_param *data, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 
 	switch (data->flags & IW_AUTH_INDEX) {
@@ -3221,7 +3221,7 @@ static int prism2_ioctl_siwencodeext(struct net_device *dev,
 				     struct iw_request_info *info,
 				     struct iw_point *erq, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	struct iw_encode_ext *ext = (struct iw_encode_ext *) extra;
 	int i, ret = 0;
@@ -3395,7 +3395,7 @@ static int prism2_ioctl_giwencodeext(struct net_device *dev,
 				     struct iw_request_info *info,
 				     struct iw_point *erq, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	struct ieee80211_crypt_data **crypt;
 	void *sta_ptr;
@@ -3716,7 +3716,7 @@ static int prism2_ioctl_giwgenie(struct net_device *dev,
 				 struct iw_request_info *info,
 				 struct iw_point *data, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	int len = local->generic_elem_len - 2;
 
@@ -3755,7 +3755,7 @@ static int prism2_ioctl_siwmlme(struct net_device *dev,
 				struct iw_request_info *info,
 				struct iw_point *data, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	struct iw_mlme *mlme = (struct iw_mlme *) extra;
 	u16 reason;
diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
index 87a54aa..a42325c 100644
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -3,6 +3,7 @@
 
 #include <linux/wireless.h>
 #include <linux/netdevice.h>
+#include <linux/mutex.h>
 #include <net/iw_handler.h>
 
 #include "hostap_config.h"
@@ -641,7 +642,7 @@ struct local_info {
 			      * when removing entries from the list.
 			      * TX and RX paths can use read lock. */
 	spinlock_t cmdlock, baplock, lock;
-	struct semaphore rid_bap_sem;
+	struct mutex rid_bap_mtx;
 	u16 infofid; /* MAC buffer id for info frame */
 	/* txfid, intransmitfid, next_txtid, and next_alloc are protected by
 	 * txfidlock */
diff --git a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/orinoco_tmd.c
index 7c7b960..b9c54d8 100644
--- a/drivers/net/wireless/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco_tmd.c
@@ -190,7 +190,7 @@ static int orinoco_tmd_init_one(struct pci_dev *pdev,
 static void __devexit orinoco_tmd_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct orinoco_pci_card *card = priv->card;
 
 	unregister_netdev(dev);
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 585f599..f106661 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -1753,7 +1753,7 @@ prism54_get_oid(struct net_device *ndev, struct iw_request_info *info,
 	int rvalue;
 	enum oid_num_t n = dwrq->flags;
 
-	rvalue = mgt_get_request((islpci_private *) ndev->priv, n, 0, NULL, &r);
+	rvalue = mgt_get_request(netdev_priv(ndev), n, 0, NULL, &r);
 	dwrq->length = mgt_response_to_str(n, &r, extra);
 	if ((isl_oid[n].flags & OID_FLAG_TYPE) != OID_TYPE_U32)
 		kfree(r.ptr);
@@ -1766,7 +1766,7 @@ prism54_set_u32(struct net_device *ndev, struct iw_request_info *info,
 {
 	u32 oid = uwrq[0], u = uwrq[1];
 
-	return mgt_set_request((islpci_private *) ndev->priv, oid, 0, &u);
+	return mgt_set_request(netdev_priv(ndev), oid, 0, &u);
 }
 
 static int
@@ -1775,7 +1775,7 @@ prism54_set_raw(struct net_device *ndev, struct iw_request_info *info,
 {
 	u32 oid = dwrq->flags;
 
-	return mgt_set_request((islpci_private *) ndev->priv, oid, 0, extra);
+	return mgt_set_request(netdev_priv(ndev), oid, 0, extra);
 }
 
 void
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
index 4278032..57a4ac3 100644
--- a/drivers/net/wireless/prism54/oid_mgt.c
+++ b/drivers/net/wireless/prism54/oid_mgt.c
@@ -244,13 +244,11 @@ mgt_init(islpci_private *priv)
 	/* Alloc the cache */
 	for (i = 0; i < OID_NUM_LAST; i++) {
 		if (isl_oid[i].flags & OID_FLAG_CACHED) {
-			priv->mib[i] = kmalloc(isl_oid[i].size *
+			priv->mib[i] = kzalloc(isl_oid[i].size *
 					       (isl_oid[i].range + 1),
 					       GFP_KERNEL);
 			if (!priv->mib[i])
 				return -ENOMEM;
-			memset(priv->mib[i], 0,
-			       isl_oid[i].size * (isl_oid[i].range + 1));
 		} else
 			priv->mib[i] = NULL;
 	}
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 3be6242..1d9dbf8 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -314,7 +314,7 @@ static int ray_probe(struct pcmcia_device *p_dev)
     if (!dev)
 	    goto fail_alloc_dev;
 
-    local = dev->priv;
+    local = netdev_priv(dev);
     local->finder = p_dev;
 
     /* The io structure describes IO port mapping. None used here */
@@ -388,7 +388,7 @@ static void ray_detach(struct pcmcia_device *link)
 
     ray_release(link);
 
-    local = (ray_dev_t *)dev->priv;
+    local = netdev_priv(dev);
     del_timer(&local->timer);
 
     if (link->priv) {
@@ -412,7 +412,7 @@ static int ray_config(struct pcmcia_device *link)
     win_req_t req;
     memreq_t mem;
     struct net_device *dev = (struct net_device *)link->priv;
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
 
     DEBUG(1, "ray_config(0x%p)\n", link);
 
@@ -520,7 +520,7 @@ static int ray_init(struct net_device *dev)
     int i;
     UCHAR *p;
     struct ccs __iomem *pccs;
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link = local->finder;
     DEBUG(1, "ray_init(0x%p)\n", dev);
     if (!(pcmcia_dev_present(link))) {
@@ -581,7 +581,7 @@ static int ray_init(struct net_device *dev)
 static int dl_startup_params(struct net_device *dev)
 {
     int ccsindex;
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct ccs __iomem *pccs;
     struct pcmcia_device *link = local->finder;
 
@@ -786,7 +786,7 @@ static void join_net(u_long data)
 static void ray_release(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv; 
-    ray_dev_t *local = dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     int i;
     
     DEBUG(1, "ray_release(0x%p)\n", link);
@@ -834,7 +834,7 @@ int ray_dev_init(struct net_device *dev)
 #ifdef RAY_IMMEDIATE_INIT
     int i;
 #endif	/* RAY_IMMEDIATE_INIT */
-    ray_dev_t *local = dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link = local->finder;
 
     DEBUG(1,"ray_dev_init(dev=%p)\n",dev);
@@ -868,7 +868,7 @@ int ray_dev_init(struct net_device *dev)
 /*===========================================================================*/
 static int ray_dev_config(struct net_device *dev, struct ifmap *map)
 {
-    ray_dev_t *local = dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link = local->finder;
     /* Dummy routine to satisfy device structure */
     DEBUG(1,"ray_dev_config(dev=%p,ifmap=%p)\n",dev,map);
@@ -882,7 +882,7 @@ static int ray_dev_config(struct net_device *dev, struct ifmap *map)
 /*===========================================================================*/
 static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    ray_dev_t *local = dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link = local->finder;
     short length = skb->len;
 
@@ -925,7 +925,7 @@ static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static int ray_hw_xmit(unsigned char* data, int len, struct net_device* dev, 
                 UCHAR msg_type)
 {
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct ccs __iomem *pccs;
     int ccsindex;
     int offset;
@@ -1099,7 +1099,7 @@ static int ray_set_freq(struct net_device *dev,
 			struct iw_freq *fwrq,
 			char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 	int err = -EINPROGRESS;		/* Call commit handler */
 
 	/* Reject if card is already initialised */
@@ -1124,7 +1124,7 @@ static int ray_get_freq(struct net_device *dev,
 			struct iw_freq *fwrq,
 			char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 
 	fwrq->m = local->sparm.b5.a_hop_pattern;
 	fwrq->e = 0;
@@ -1140,7 +1140,7 @@ static int ray_set_essid(struct net_device *dev,
 			 struct iw_point *dwrq,
 			 char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 
 	/* Reject if card is already initialised */
 	if(local->card_status != CARD_AWAITING_PARAM)
@@ -1173,7 +1173,7 @@ static int ray_get_essid(struct net_device *dev,
 			 struct iw_point *dwrq,
 			 char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 
 	/* Get the essid that was set */
 	memcpy(extra, local->sparm.b5.a_current_ess_id, IW_ESSID_MAX_SIZE);
@@ -1194,7 +1194,7 @@ static int ray_get_wap(struct net_device *dev,
 			struct sockaddr *awrq,
 			char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 
 	memcpy(awrq->sa_data, local->bss_id, ETH_ALEN);
 	awrq->sa_family = ARPHRD_ETHER;
@@ -1211,7 +1211,7 @@ static int ray_set_rate(struct net_device *dev,
 			struct iw_param *vwrq,
 			char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 
 	/* Reject if card is already initialised */
 	if(local->card_status != CARD_AWAITING_PARAM)
@@ -1240,7 +1240,7 @@ static int ray_get_rate(struct net_device *dev,
 			struct iw_param *vwrq,
 			char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 
 	if(local->net_default_tx_rate == 3)
 		vwrq->value = 2000000;		/* Hum... */
@@ -1260,7 +1260,7 @@ static int ray_set_rts(struct net_device *dev,
 		       struct iw_param *vwrq,
 		       char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 	int rthr = vwrq->value;
 
 	/* Reject if card is already initialised */
@@ -1290,7 +1290,7 @@ static int ray_get_rts(struct net_device *dev,
 		       struct iw_param *vwrq,
 		       char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 
 	vwrq->value = (local->sparm.b5.a_rts_threshold[0] << 8)
 		+ local->sparm.b5.a_rts_threshold[1];
@@ -1309,7 +1309,7 @@ static int ray_set_frag(struct net_device *dev,
 			struct iw_param *vwrq,
 			char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 	int fthr = vwrq->value;
 
 	/* Reject if card is already initialised */
@@ -1338,7 +1338,7 @@ static int ray_get_frag(struct net_device *dev,
 			struct iw_param *vwrq,
 			char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 
 	vwrq->value = (local->sparm.b5.a_frag_threshold[0] << 8)
 		+ local->sparm.b5.a_frag_threshold[1];
@@ -1357,7 +1357,7 @@ static int ray_set_mode(struct net_device *dev,
 			__u32 *uwrq,
 			char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 	int err = -EINPROGRESS;		/* Call commit handler */
 	char card_mode = 1;
 
@@ -1389,7 +1389,7 @@ static int ray_get_mode(struct net_device *dev,
 			__u32 *uwrq,
 			char *extra)
 {
-	ray_dev_t *local = (ray_dev_t *)dev->priv;
+	ray_dev_t *local = netdev_priv(dev);
 
 	if(local->sparm.b5.a_network_type)
 		*uwrq = IW_MODE_INFRA;
@@ -1492,7 +1492,7 @@ static int ray_commit(struct net_device *dev,
  */
 static iw_stats * ray_get_wireless_stats(struct net_device *	dev)
 {
-  ray_dev_t *	local = (ray_dev_t *) dev->priv;
+  ray_dev_t *	local = netdev_priv(dev);
   struct pcmcia_device *link = local->finder;
   struct status __iomem *p = local->sram + STATUS_BASE;
 
@@ -1580,7 +1580,7 @@ static const struct iw_handler_def	ray_handler_def =
 /*===========================================================================*/
 static int ray_open(struct net_device *dev)
 {
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link;
     link = local->finder;
     
@@ -1614,7 +1614,7 @@ static int ray_open(struct net_device *dev)
 /*===========================================================================*/
 static int ray_dev_close(struct net_device *dev)
 {
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link;
     link = local->finder;
 
@@ -1773,7 +1773,7 @@ static int parse_addr(char *in_str, UCHAR *out)
 /*===========================================================================*/
 static struct net_device_stats *ray_get_stats(struct net_device *dev)
 {
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link = local->finder;
     struct status __iomem *p = local->sram + STATUS_BASE;
     if (!(pcmcia_dev_present(link))) {
@@ -1803,7 +1803,7 @@ static struct net_device_stats *ray_get_stats(struct net_device *dev)
 /*===========================================================================*/
 static void ray_update_parm(struct net_device *dev, UCHAR objid, UCHAR *value, int len)
 {
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link = local->finder;
     int ccsindex;
     int i;
@@ -1840,7 +1840,7 @@ static void ray_update_multi_list(struct net_device *dev, int all)
     int ccsindex;
     struct ccs __iomem *pccs;
     int i = 0;
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link = local->finder;
     void __iomem *p = local->sram + HOST_TO_ECF_BASE;
 
@@ -1884,7 +1884,7 @@ static void ray_update_multi_list(struct net_device *dev, int all)
 /*===========================================================================*/
 static void set_multicast_list(struct net_device *dev)
 {
-    ray_dev_t *local = (ray_dev_t *)dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     UCHAR promisc;
 
     DEBUG(2,"ray_cs set_multicast_list(%p)\n",dev);
@@ -1935,7 +1935,7 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 
     DEBUG(4,"ray_cs: interrupt for *dev=%p\n",dev);
 
-    local = (ray_dev_t *)dev->priv;
+    local = netdev_priv(dev);
     link = (struct pcmcia_device *)local->finder;
     if (!pcmcia_dev_present(link)) {
         DEBUG(2,"ray_cs interrupt from device not present or suspended.\n");
@@ -2165,7 +2165,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs, unsigned i
 {
     struct sk_buff *skb = NULL;
     struct rcs __iomem *prcslink = prcs;
-    ray_dev_t *local = dev->priv;
+    ray_dev_t *local = netdev_priv(dev);
     UCHAR *rx_ptr;
     int total_len;
     int tmp;
@@ -2618,7 +2618,7 @@ static int ray_cs_proc_read(char *buf, char **start, off_t offset, int len)
     dev = (struct net_device *)link->priv;
     if (!dev)
     	return 0;
-    local = (ray_dev_t *)dev->priv;
+    local = netdev_priv(dev);
     if (!local)
     	return 0;
 
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index ef32a5c..ed146ae 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -2571,7 +2571,7 @@ static struct strip *strip_alloc(void)
 		return NULL;	/* If no more memory, return */
 
 
-	strip_info = dev->priv;
+	strip_info = netdev_priv(dev);
 	strip_info->dev = dev;
 
 	strip_info->magic = STRIP_MAGIC;
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index c8b5c22..72f3d97 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -859,7 +859,7 @@ static int wl3501_esbq_confirm(struct wl3501_card *this)
 
 static void wl3501_online(struct net_device *dev)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	printk(KERN_INFO "%s: Wireless LAN online. BSSID: "
 	       "%02X %02X %02X %02X %02X %02X\n", dev->name,
@@ -907,7 +907,7 @@ static int wl3501_mgmt_association(struct wl3501_card *this)
 
 static void wl3501_mgmt_join_confirm(struct net_device *dev, u16 addr)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	struct wl3501_join_confirm sig;
 
 	dprintk(3, "entry");
@@ -1046,7 +1046,7 @@ static inline void wl3501_start_confirm_interrupt(struct net_device *dev,
 static inline void wl3501_assoc_confirm_interrupt(struct net_device *dev,
 						  u16 addr)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	struct wl3501_assoc_confirm sig;
 
 	dprintk(3, "entry");
@@ -1075,7 +1075,7 @@ static inline void wl3501_rx_interrupt(struct net_device *dev)
 	int morepkts;
 	u16 addr;
 	u8 sig_id;
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	dprintk(3, "entry");
 loop:
@@ -1257,7 +1257,7 @@ fail:
 
 static int wl3501_close(struct net_device *dev)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int rc = -ENODEV;
 	unsigned long flags;
 	struct pcmcia_device *link;
@@ -1289,7 +1289,7 @@ static int wl3501_close(struct net_device *dev)
  */
 static int wl3501_reset(struct net_device *dev)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int rc = -ENODEV;
 
 	wl3501_block_interrupt(this);
@@ -1318,7 +1318,7 @@ out:
 
 static void wl3501_tx_timeout(struct net_device *dev)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	struct net_device_stats *stats = &this->stats;
 	unsigned long flags;
 	int rc;
@@ -1344,7 +1344,7 @@ static void wl3501_tx_timeout(struct net_device *dev)
 static int wl3501_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int enabled, rc;
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&this->lock, flags);
@@ -1371,7 +1371,7 @@ static int wl3501_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static int wl3501_open(struct net_device *dev)
 {
 	int rc = -ENODEV;
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	unsigned long flags;
 	struct pcmcia_device *link;
 	link = this->p_dev;
@@ -1410,14 +1410,14 @@ fail:
 
 static struct net_device_stats *wl3501_get_stats(struct net_device *dev)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	return &this->stats;
 }
 
 static struct iw_statistics *wl3501_get_wireless_stats(struct net_device *dev)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	struct iw_statistics *wstats = &this->wstats;
 	u32 value; /* size checked: it is u32 */
 
@@ -1497,7 +1497,7 @@ static int wl3501_get_name(struct net_device *dev, struct iw_request_info *info,
 static int wl3501_set_freq(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int channel = wrqu->freq.m;
 	int rc = -EINVAL;
 
@@ -1511,7 +1511,7 @@ static int wl3501_set_freq(struct net_device *dev, struct iw_request_info *info,
 static int wl3501_get_freq(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	wrqu->freq.m = wl3501_chan2freq[this->chan - 1] * 100000;
 	wrqu->freq.e = 1;
@@ -1526,7 +1526,7 @@ static int wl3501_set_mode(struct net_device *dev, struct iw_request_info *info,
 	if (wrqu->mode == IW_MODE_INFRA ||
 	    wrqu->mode == IW_MODE_ADHOC ||
 	    wrqu->mode == IW_MODE_AUTO) {
-		struct wl3501_card *this = dev->priv;
+		struct wl3501_card *this = netdev_priv(dev);
 
 		this->net_type = wrqu->mode;
 		rc = wl3501_reset(dev);
@@ -1537,7 +1537,7 @@ static int wl3501_set_mode(struct net_device *dev, struct iw_request_info *info,
 static int wl3501_get_mode(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	wrqu->mode = this->net_type;
 	return 0;
@@ -1546,7 +1546,7 @@ static int wl3501_get_mode(struct net_device *dev, struct iw_request_info *info,
 static int wl3501_get_sens(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	wrqu->sens.value = this->rssi;
 	wrqu->sens.disabled = !wrqu->sens.value;
@@ -1577,7 +1577,7 @@ static int wl3501_get_range(struct net_device *dev,
 static int wl3501_set_wap(struct net_device *dev, struct iw_request_info *info,
 			  union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	static const u8 bcast[ETH_ALEN] = { 255, 255, 255, 255, 255, 255 };
 	int rc = -EINVAL;
 
@@ -1597,7 +1597,7 @@ out:
 static int wl3501_get_wap(struct net_device *dev, struct iw_request_info *info,
 			  union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	wrqu->ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(wrqu->ap_addr.sa_data, this->bssid, ETH_ALEN);
@@ -1616,7 +1616,7 @@ static int wl3501_set_scan(struct net_device *dev, struct iw_request_info *info,
 static int wl3501_get_scan(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int i;
 	char *current_ev = extra;
 	struct iw_event iwe;
@@ -1666,7 +1666,7 @@ static int wl3501_set_essid(struct net_device *dev,
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	if (wrqu->data.flags) {
 		iw_set_mgmt_info_element(IW_MGMT_INFO_ELEMENT_SSID,
@@ -1683,7 +1683,7 @@ static int wl3501_get_essid(struct net_device *dev,
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&this->lock, flags);
@@ -1697,7 +1697,7 @@ static int wl3501_get_essid(struct net_device *dev,
 static int wl3501_set_nick(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	if (wrqu->data.length > sizeof(this->nick))
 		return -E2BIG;
@@ -1708,7 +1708,7 @@ static int wl3501_set_nick(struct net_device *dev, struct iw_request_info *info,
 static int wl3501_get_nick(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 
 	strlcpy(extra, this->nick, 32);
 	wrqu->data.length = strlen(extra);
@@ -1733,7 +1733,7 @@ static int wl3501_get_rts_threshold(struct net_device *dev,
 				    union iwreq_data *wrqu, char *extra)
 {
 	u16 threshold; /* size checked: it is u16 */
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int rc = wl3501_get_mib_value(this, WL3501_MIB_ATTR_RTS_THRESHOLD,
 				      &threshold, sizeof(threshold));
 	if (!rc) {
@@ -1749,7 +1749,7 @@ static int wl3501_get_frag_threshold(struct net_device *dev,
 				     union iwreq_data *wrqu, char *extra)
 {
 	u16 threshold; /* size checked: it is u16 */
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int rc = wl3501_get_mib_value(this, WL3501_MIB_ATTR_FRAG_THRESHOLD,
 				      &threshold, sizeof(threshold));
 	if (!rc) {
@@ -1765,7 +1765,7 @@ static int wl3501_get_txpow(struct net_device *dev,
 			    union iwreq_data *wrqu, char *extra)
 {
 	u16 txpow;
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int rc = wl3501_get_mib_value(this,
 				      WL3501_MIB_ATTR_CURRENT_TX_PWR_LEVEL,
 				      &txpow, sizeof(txpow));
@@ -1787,7 +1787,7 @@ static int wl3501_get_retry(struct net_device *dev,
 			    union iwreq_data *wrqu, char *extra)
 {
 	u8 retry; /* size checked: it is u8 */
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int rc = wl3501_get_mib_value(this,
 				      WL3501_MIB_ATTR_LONG_RETRY_LIMIT,
 				      &retry, sizeof(retry));
@@ -1814,7 +1814,7 @@ static int wl3501_get_encode(struct net_device *dev,
 			     union iwreq_data *wrqu, char *extra)
 {
 	u8 implemented, restricted, keys[100], len_keys, tocopy;
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int rc = wl3501_get_mib_value(this,
 				      WL3501_MIB_ATTR_PRIV_OPT_IMPLEMENTED,
 				      &implemented, sizeof(implemented));
@@ -1852,7 +1852,7 @@ static int wl3501_get_power(struct net_device *dev,
 			    union iwreq_data *wrqu, char *extra)
 {
 	u8 pwr_state;
-	struct wl3501_card *this = dev->priv;
+	struct wl3501_card *this = netdev_priv(dev);
 	int rc = wl3501_get_mib_value(this,
 				      WL3501_MIB_ATTR_CURRENT_PWR_STATE,
 				      &pwr_state, sizeof(pwr_state));
@@ -1937,7 +1937,7 @@ static int wl3501_probe(struct pcmcia_device *p_dev)
 	dev->tx_timeout		= wl3501_tx_timeout;
 	dev->watchdog_timeo	= 5 * HZ;
 	dev->get_stats		= wl3501_get_stats;
-	this = dev->priv;
+	this = netdev_priv(dev);
 	this->wireless_data.spy_data = &this->spy_data;
 	this->p_dev = p_dev;
 	dev->wireless_data	= &this->wireless_data;
@@ -2006,7 +2006,7 @@ static int wl3501_config(struct pcmcia_device *link)
 
 	SET_MODULE_OWNER(dev);
 
-	this = dev->priv;
+	this = netdev_priv(dev);
 	/*
 	 * At this point, the dev_node_t structure(s) should be initialized and
 	 * arranged in a linked list at link->dev_node.
@@ -2079,7 +2079,7 @@ static int wl3501_suspend(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
 
-	wl3501_pwr_mgmt(dev->priv, WL3501_SUSPEND);
+	wl3501_pwr_mgmt(netdev_priv(dev), WL3501_SUSPEND);
 	if (link->open)
 		netif_device_detach(dev);
 
@@ -2090,7 +2090,7 @@ static int wl3501_resume(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
 
-	wl3501_pwr_mgmt(dev->priv, WL3501_RESUME);
+	wl3501_pwr_mgmt(netdev_priv(dev), WL3501_RESUME);
 	if (link->open) {
 		wl3501_reset(dev);
 		netif_device_attach(dev);
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index f469857..8009b70 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -871,11 +871,6 @@ static inline int zd_chip_set_basic_rates(struct zd_chip *chip, u16 cr_rates)
 	return r;
 }
 
-static inline int zd_chip_set_rx_filter(struct zd_chip *chip, u32 filter)
-{
-	return zd_iowrite32(chip, CR_RX_FILTER, filter);
-}
-
 int zd_chip_lock_phy_regs(struct zd_chip *chip);
 int zd_chip_unlock_phy_regs(struct zd_chip *chip);
 
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 26869d1..7ec1fcf 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -161,13 +161,33 @@ void zd_mac_clear(struct zd_mac *mac)
 	ZD_MEMCLEAR(mac, sizeof(struct zd_mac));
 }
 
-static int reset_mode(struct zd_mac *mac)
+static int set_rx_filter(struct zd_mac *mac)
 {
 	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 	u32 filter = (ieee->iw_mode == IW_MODE_MONITOR) ? ~0 : STA_RX_FILTER;
 	return zd_iowrite32(&mac->chip, CR_RX_FILTER, filter);
 }
 
+static int set_sniffer(struct zd_mac *mac)
+{
+	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+	return zd_iowrite32(&mac->chip, CR_SNIFFER_ON,
+		ieee->iw_mode == IW_MODE_MONITOR ? 1 : 0);
+	return 0;
+}
+
+static int set_mc_hash(struct zd_mac *mac)
+{
+	struct zd_mc_hash hash;
+	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+
+	zd_mc_clear(&hash);
+	if (ieee->iw_mode == IW_MODE_MONITOR)
+		zd_mc_add_all(&hash);
+
+	return zd_chip_set_multicast_hash(&mac->chip, &hash);
+}
+
 int zd_mac_open(struct net_device *netdev)
 {
 	struct zd_mac *mac = zd_netdev_mac(netdev);
@@ -194,7 +214,13 @@ int zd_mac_open(struct net_device *netdev)
 	r = zd_chip_set_basic_rates(chip, CR_RATES_80211B | CR_RATES_80211G);
 	if (r < 0)
 		goto disable_int;
-	r = reset_mode(mac);
+	r = set_rx_filter(mac);
+	if (r)
+		goto disable_int;
+	r = set_sniffer(mac);
+	if (r)
+		goto disable_int;
+	r = set_mc_hash(mac);
 	if (r)
 		goto disable_int;
 	r = zd_chip_switch_radio_on(chip);
@@ -298,12 +324,14 @@ static void set_multicast_hash_handler(struct work_struct *work)
 
 void zd_mac_set_multicast_list(struct net_device *dev)
 {
-	struct zd_mc_hash hash;
 	struct zd_mac *mac = zd_netdev_mac(dev);
+	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+	struct zd_mc_hash hash;
 	struct dev_mc_list *mc;
 	unsigned long flags;
 
-	if (dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) {
+	if (dev->flags & (IFF_PROMISC|IFF_ALLMULTI) ||
+			ieee->iw_mode == IW_MODE_MONITOR) {
 		zd_mc_add_all(&hash);
 	} else {
 		zd_mc_clear(&hash);
@@ -628,8 +656,12 @@ int zd_mac_set_mode(struct zd_mac *mac, u32 mode)
 	ieee->iw_mode = mode;
 	spin_unlock_irq(&ieee->lock);
 
-	if (netif_running(mac->netdev))
-		return reset_mode(mac);
+	if (netif_running(mac->netdev)) {
+		int r = set_rx_filter(mac);
+		if (r)
+			return r;
+		return set_sniffer(mac);
+	}
 
 	return 0;
 }
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
