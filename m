From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 29/33] pcmcia: convert DEV_OK to pcmcia_dev_present
Date: Fri, 31 Mar 2006 22:30:14 +0200
Message-ID: <20060331203014.GH28168@dominikbrodowski.de>
References: <20060331195852.GB27888@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-serial@vger.kernel.org,
	alsa-devel@alsa-project.org, laforge@gnumonks.org
Return-path: <alsa-devel-admin@lists.sourceforge.net>
To: linux-pcmcia@lists.infradead.org
Content-Disposition: inline
In-Reply-To: <20060331195852.GB27888@dominikbrodowski.de>
Sender: alsa-devel-admin@lists.sourceforge.net
Errors-To: alsa-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:alsa-devel@lists.sourceforge.net>
List-Help: <mailto:alsa-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=alsa-devel>
List-Id: netdev.vger.kernel.org

Instead of the DEV_OK macro, drivers should use pcmcia_dev_present().

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

---

 drivers/char/pcmcia/cm4000_cs.c         |    4 ++--
 drivers/char/pcmcia/cm4040_cs.c         |    2 +-
 drivers/net/pcmcia/3c574_cs.c           |    4 ++--
 drivers/net/pcmcia/3c589_cs.c           |    8 ++++----
 drivers/net/pcmcia/axnet_cs.c           |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c         |    2 +-
 drivers/net/pcmcia/nmclan_cs.c          |    2 +-
 drivers/net/pcmcia/pcnet_cs.c           |    2 +-
 drivers/net/pcmcia/smc91c92_cs.c        |    2 +-
 drivers/net/pcmcia/xirc2ps_cs.c         |    2 +-
 drivers/net/wireless/atmel_cs.c         |    9 ++++-----
 drivers/net/wireless/hostap/hostap_cs.c |    2 +-
 drivers/net/wireless/netwave_cs.c       |    4 ++--
 drivers/net/wireless/ray_cs.c           |    2 +-
 drivers/net/wireless/wl3501_cs.c        |    2 +-
 drivers/pcmcia/ds.c                     |   27 +++++++++++++++++++++++++++
 drivers/serial/serial_cs.c              |    2 +-
 include/pcmcia/cs.h                     |    1 +
 include/pcmcia/ds.h                     |   12 ++++--------
 sound/pcmcia/pdaudiocf/pdaudiocf.c      |    2 +-
 sound/pcmcia/vx/vxpocket.c              |    2 +-
 21 files changed, 59 insertions(+), 36 deletions(-)

9940ec3617fec1db13e589bbc3f37e37878c7683
diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index 16e105d..02114a0 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -1458,7 +1458,7 @@ static int cmm_ioctl(struct inode *inode
 	       iminor(inode), ioctl_names[_IOC_NR(cmd)]);
 
 	link = dev_table[iminor(inode)];
-	if (!(DEV_OK(link))) {
+	if (!pcmcia_dev_present(link)) {
 		DEBUGP(4, dev, "DEV_OK false\n");
 		return -ENODEV;
 	}
@@ -1667,7 +1667,7 @@ static int cmm_open(struct inode *inode,
 		return -ENODEV;
 
 	link = dev_table[minor];
-	if (link == NULL || !(DEV_OK(link)))
+	if (link == NULL || !pcmcia_dev_present(link))
 		return -ENODEV;
 
 	if (link->open)
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index 74609c3..29efa64 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -452,7 +452,7 @@ static int cm4040_open(struct inode *ino
 		return -ENODEV;
 
 	link = dev_table[minor];
-	if (link == NULL || !(DEV_OK(link)))
+	if (link == NULL || !pcmcia_dev_present(link))
 		return -ENODEV;
 
 	if (link->open)
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 70e3cca..fab9336 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -728,7 +728,7 @@ static int el3_open(struct net_device *d
 	struct el3_private *lp = netdev_priv(dev);
 	struct pcmcia_device *link = lp->p_dev;
 
-	if (!DEV_OK(link))
+	if (!pcmcia_dev_present(link))
 		return -ENODEV;
 	
 	link->open++;
@@ -1176,7 +1176,7 @@ static int el3_close(struct net_device *
 
 	DEBUG(2, "%s: shutting down ethercard.\n", dev->name);
 	
-	if (DEV_OK(link)) {
+	if (pcmcia_dev_present(link)) {
 		unsigned long flags;
 
 		/* Turn off statistics ASAP.  We update lp->stats below. */
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 3d05f66..875a0fe 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -557,7 +557,7 @@ static int el3_open(struct net_device *d
     struct el3_private *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
     
-    if (!DEV_OK(link))
+    if (!pcmcia_dev_present(link))
 	return -ENODEV;
 
     link->open++;
@@ -818,7 +818,7 @@ static struct net_device_stats *el3_get_
     unsigned long flags;
     struct pcmcia_device *link = lp->p_dev;
 
-    if (DEV_OK(link)) {
+    if (pcmcia_dev_present(link)) {
     	spin_lock_irqsave(&lp->lock, flags);
 	update_stats(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -922,7 +922,7 @@ static void set_multicast_list(struct ne
     kio_addr_t ioaddr = dev->base_addr;
     u16 opts = SetRxFilter | RxStation | RxBroadcast;
 
-    if (!(DEV_OK(link))) return;
+    if (!pcmcia_dev_present(link)) return;
     if (dev->flags & IFF_PROMISC)
 	opts |= RxMulticast | RxProm;
     else if (dev->mc_count || (dev->flags & IFF_ALLMULTI))
@@ -938,7 +938,7 @@ static int el3_close(struct net_device *
     
     DEBUG(1, "%s: shutting down ethercard.\n", dev->name);
 
-    if (DEV_OK(link)) {
+    if (pcmcia_dev_present(link)) {
 	/* Turn off statistics ASAP.  We update lp->stats below. */
 	outw(StatsDisable, ioaddr + EL3_CMD);
 	
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 0f1219c..56233af 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -530,7 +530,7 @@ static int axnet_open(struct net_device 
     
     DEBUG(2, "axnet_open('%s')\n", dev->name);
 
-    if (!DEV_OK(link))
+    if (!pcmcia_dev_present(link))
 	return -ENODEV;
 
     link->open++;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 7cb20b6..09b1176 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -1112,7 +1112,7 @@ static int fjn_open(struct net_device *d
 
     DEBUG(4, "fjn_open('%s').\n", dev->name);
 
-    if (!DEV_OK(link))
+    if (!pcmcia_dev_present(link))
 	return -ENODEV;
     
     link->open++;
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index fd19114..4260c21 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -853,7 +853,7 @@ static int mace_open(struct net_device *
   mace_private *lp = netdev_priv(dev);
   struct pcmcia_device *link = lp->p_dev;
 
-  if (!DEV_OK(link))
+  if (!pcmcia_dev_present(link))
     return -ENODEV;
 
   link->open++;
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index d966141..506e777 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -992,7 +992,7 @@ static int pcnet_open(struct net_device 
 
     DEBUG(2, "pcnet_open('%s')\n", dev->name);
 
-    if (!DEV_OK(link))
+    if (!pcmcia_dev_present(link))
 	return -ENODEV;
 
     link->open++;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 7d565f2..e74bf50 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1259,7 +1259,7 @@ static int smc_open(struct net_device *d
 #endif
 
     /* Check that the PCMCIA card is still here. */
-    if (!DEV_OK(link))
+    if (!pcmcia_dev_present(link))
 	return -ENODEV;
     /* Physical device present signature. */
     if (check_sig(link) < 0) {
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 0141c50..a92a313 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1525,7 +1525,7 @@ do_open(struct net_device *dev)
 
     /* Check that the PCMCIA card is still here. */
     /* Physical device present signature. */
-    if (!DEV_OK(link))
+    if (!pcmcia_dev_present(link))
 	return -ENODEV;
 
     /* okay */
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 25fb919..26bf112 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -216,13 +216,12 @@ do { last_fn = (fn); if ((last_ret = (re
 /* Call-back function to interrogate PCMCIA-specific information
    about the current existance of the card */
 static int card_present(void *arg)
-{ 
+{
 	struct pcmcia_device *link = (struct pcmcia_device *)arg;
-	if (link->suspended)
-		return 0;
-	else if (pcmcia_dev_present(link))
+
+	if (pcmcia_dev_present(link))
 		return 1;
-	
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index a2cb9b0..55bed92 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -210,7 +210,7 @@ static int prism2_config(struct pcmcia_d
 static int prism2_pccard_card_present(local_info_t *local)
 {
 	struct hostap_cs_priv *hw_priv = local->hw_priv;
-	if (hw_priv != NULL && hw_priv->link != NULL && DEV_OK(hw_priv->link))
+	if (hw_priv != NULL && hw_priv->link != NULL && pcmcia_dev_present(hw_priv->link))
 		return 1;
 	return 0;
 }
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index fbc8595..9343d97 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -1107,7 +1107,7 @@ static irqreturn_t netwave_interrupt(int
 	
         status = inb(iobase + NETWAVE_REG_ASR);
 		
-	if (!DEV_OK(link)) {
+	if (!pcmcia_dev_present(link)) {
 	    DEBUG(1, "netwave_interrupt: Interrupt with status 0x%x "
 		  "from removed or suspended card!\n", status);
 	    break;
@@ -1346,7 +1346,7 @@ static int netwave_open(struct net_devic
 
     DEBUG(1, "netwave_open: starting.\n");
     
-    if (!DEV_OK(link))
+    if (!pcmcia_dev_present(link))
 	return -ENODEV;
 
     link->open++;
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 85712ff..879eb42 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1961,7 +1961,7 @@ static irqreturn_t ray_interrupt(int irq
 
     local = (ray_dev_t *)dev->priv;
     link = (struct pcmcia_device *)local->finder;
-    if (!(pcmcia_dev_present(link))  || link->suspended ) {
+    if (!pcmcia_dev_present(link)) {
         DEBUG(2,"ray_cs interrupt from device not present or suspended.\n");
         return IRQ_NONE;
     }
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index b657805..e52a650 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1387,7 +1387,7 @@ static int wl3501_open(struct net_device
 	link = this->p_dev;
 
 	spin_lock_irqsave(&this->lock, flags);
-	if (!DEV_OK(link))
+	if (!pcmcia_dev_present(link))
 		goto out;
 	netif_device_attach(dev);
 	link->open++;
diff --git a/drivers/pcmcia/ds.c b/drivers/pcmcia/ds.c
index 8c87343..677105e 100644
--- a/drivers/pcmcia/ds.c
+++ b/drivers/pcmcia/ds.c
@@ -469,6 +469,7 @@ static void pcmcia_card_remove(struct pc
 		}
 		p_dev = list_entry((&s->devices_list)->next, struct pcmcia_device, socket_device_list);
 		list_del(&p_dev->socket_device_list);
+		p_dev->_removed=1;
 		spin_unlock_irqrestore(&pcmcia_dev_list_lock, flags);
 
 		device_unregister(&p_dev->dev);
@@ -1163,6 +1164,32 @@ static int ds_event(struct pcmcia_socket
 } /* ds_event */
 
 
+struct pcmcia_device * pcmcia_dev_present(struct pcmcia_device *_p_dev)
+{
+	struct pcmcia_device *p_dev;
+	struct pcmcia_device *ret = NULL;
+
+	p_dev = pcmcia_get_dev(_p_dev);
+	if (!p_dev)
+		return NULL;
+
+	if (!p_dev->socket->pcmcia_state.present)
+		goto out;
+
+	if (p_dev->_removed)
+		goto out;
+
+	if (p_dev->suspended)
+		goto out;
+
+	ret = p_dev;
+ out:
+	pcmcia_put_dev(p_dev);
+	return ret;
+}
+EXPORT_SYMBOL(pcmcia_dev_present);
+
+
 static struct pcmcia_callback pcmcia_bus_callback = {
 	.owner = THIS_MODULE,
 	.event = ds_event,
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index eec05a0..389d847 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -155,7 +155,7 @@ static int serial_suspend(struct pcmcia_
 
 static int serial_resume(struct pcmcia_device *link)
 {
-	if (DEV_OK(link)) {
+	if (pcmcia_dev_present(link)) {
 		struct serial_info *info = link->priv;
 		int i;
 
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index e0835d6..d5838c3 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -390,6 +390,7 @@ int pcmcia_eject_card(struct pcmcia_sock
 int pcmcia_insert_card(struct pcmcia_socket *skt);
 int pccard_reset_card(struct pcmcia_socket *skt);
 
+struct pcmcia_device * pcmcia_dev_present(struct pcmcia_device *p_dev);
 void pcmcia_disable_device(struct pcmcia_device *p_dev);
 
 struct pcmcia_socket * pcmcia_get_socket(struct pcmcia_socket *skt);
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index a8ce8fc..8c339f5 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -104,12 +104,6 @@ typedef struct dev_node_t {
     struct dev_node_t	*next;
 } dev_node_t;
 
-#define pcmcia_dev_present(p_dev) \
-    (p_dev->socket->pcmcia_state.present)
-
-#define DEV_OK(l) \
-    ((l) && (!l->suspended) && pcmcia_dev_present(l))
-
 
 struct pcmcia_socket;
 struct config_t;
@@ -155,8 +149,10 @@ struct pcmcia_device {
 	config_req_t		conf;
 	window_handle_t		win;
 
-	/* Is the device suspended? */
+	/* Is the device suspended, or in the process of
+	 * being removed? */
 	u16			suspended:1;
+	u16			_removed:1;
 
 	/* Flags whether io, irq, win configurations were
 	 * requested, and whether the configuration is "locked" */
@@ -174,7 +170,7 @@ struct pcmcia_device {
 	u16			has_card_id:1;
 	u16			has_func_id:1;
 
-	u16			reserved:4;
+	u16			reserved:3;
 
 	u8			func_id;
 	u16			manf_id;
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index a1333fa..adfdce7 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -280,7 +280,7 @@ static int pdacf_resume(struct pcmcia_de
 	struct snd_pdacf *chip = link->priv;
 
 	snd_printdd(KERN_DEBUG "RESUME\n");
-	if (DEV_OK(link)) {
+	if (pcmcia_dev_present(link)) {
 		if (chip) {
 			snd_printdd(KERN_DEBUG "calling snd_pdacf_resume\n");
 			snd_pdacf_resume(chip);
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index f5f4a57..7e0cda2 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -291,7 +291,7 @@ static int vxp_resume(struct pcmcia_devi
 	struct vx_core *chip = link->priv;
 
 	snd_printdd(KERN_DEBUG "RESUME\n");
-	if (DEV_OK(link)) {
+	if (pcmcia_dev_present(link)) {
 		//struct snd_vxpocket *vxp = (struct snd_vxpocket *)chip;
 		if (chip) {
 			snd_printdd(KERN_DEBUG "calling snd_vx_resume\n");
-- 
1.2.4



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
