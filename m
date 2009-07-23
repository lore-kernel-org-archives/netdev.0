From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
 in  back trace (regression)
Date: Thu, 23 Jul 2009 00:01:00 -0700
Message-ID: <20090723000100.d74d6b1c.akpm@linux-foundation.org>
References: <bug-13760-10286@http.bugzilla.kernel.org/>
	<20090722134557.2457c5f5.akpm@linux-foundation.org>
	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54368 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752821AbZGWHBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 03:01:31 -0400
In-Reply-To: <43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jul 2009 14:39:29 +0800 Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com> wrote:

> 2009/7/23 Andrew Morton <akpm@linux-foundation.org>:
> >
> > (switched to email. __Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> >
> > On Sat, 11 Jul 2009 06:10:00 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> >
> >> http://bugzilla.kernel.org/show_bug.cgi?id=13760
> >>
> >> __ __ __ __ __ __Summary: 2.6.30 kernel locks up with pppoe in back trace
> >> __ __ __ __ __ __ __ __ __ __ (regression)
> >> __ __ __ __ __ __Product: Networking
> >> __ __ __ __ __ __Version: 2.5
> >> __ __ Kernel Version: 2.6.30
> >> __ __ __ __ __ Platform: All
> >> __ __ __ __ OS/Version: Linux
> >> __ __ __ __ __ __ __ Tree: Mainline
> >> __ __ __ __ __ __ Status: NEW
> >> __ __ __ __ __ Severity: normal
> >> __ __ __ __ __ Priority: P1
> >> __ __ __ __ __Component: Other
> >> __ __ __ __ AssignedTo: acme@ghostprotocols.net
> >> __ __ __ __ ReportedBy: for.poige+bugzilla.kernel.org@gmail.com
> >> __ __ __ __ Regression: Yes
> >>
> >>
> >> Having updated kernel to 2.6.30 (and 2.6.30.1) I've faced several lock-ups
> >> during boot sequence (and even during shutdown), when pppoe connection had been
> >> initiated (and interrupted on shutdown). The lock-ups aren't Alt_SysRq_B
> >> breakable.
> >>
> >> I still not have backtraces saved but as soon as pppoe connection initiation
> >> runs before running X-server (and after its shutdown), I have seen parts of
> >> dmesg's output and to my surprise it was regarding pppoe's functions.
> >>
> >
> > This regression report is nearly two weeks old and I think there has
> > been a bit of ppp-related fixing going on in that time.
> >
> > Can you please tell us whether the regression is still present in
> > 2.6.30.2? __If so, I expect we'll be wanting to see those traces,
> > please.
> >
> 	Just repeating the same thing I had written in the Bugzilla: I
> haven't noticed any changes to pppoe during last commits to 2.6.30.
> Why do you think there's a chance that bug(s) would have been fixed?

Could have been a problem in net core, perhaps.

Below is a ppp fix from 2.6.31, but it seems unlikely to fix your problem.

It would help if we could see that trace, please.  A digital photo
would suit.


commit adeab1afb7de89555c69aab5ca21300c14af6369
Author:     Ralf Baechle <ralf@linux-mips.org>
AuthorDate: Sun Jul 12 21:09:20 2009 -0700
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Sun Jul 12 21:09:20 2009 -0700

    NET: Fix locking issues in PPP, 6pack, mkiss and strip line disciplines.
    
    Guido Trentalancia reports:
    
    I am trying to use the kiss driver in the Linux kernel that is being
    shipped with Fedora 10 but unfortunately I get the following oops:
    
    mkiss: AX.25 Multikiss, Hans Albas PE1AYX
    mkiss: ax0: crc mode is auto.
    ADDRCONF(NETDEV_CHANGE): ax0: link becomes ready
    ------------[ cut here ]------------
    WARNING: at kernel/softirq.c:77 __local_bh_disable+0x2f/0x83() (Not
    tainted)
    [...]
    unloaded: microcode]
    Pid: 0, comm: swapper Not tainted 2.6.27.25-170.2.72.fc10.i686 #1
     [<c042ddfb>] warn_on_slowpath+0x65/0x8b
     [<c06ab62b>] ? _spin_unlock_irqrestore+0x22/0x38
     [<c04228b4>] ? __enqueue_entity+0xe3/0xeb
     [<c042431e>] ? enqueue_entity+0x203/0x20b
     [<c0424361>] ? enqueue_task_fair+0x3b/0x3f
     [<c041f88c>] ? resched_task+0x3a/0x6e
     [<c06ab62b>] ? _spin_unlock_irqrestore+0x22/0x38
     [<c06ab4e2>] ? _spin_lock_bh+0xb/0x16
     [<c043255b>] __local_bh_disable+0x2f/0x83
     [<c04325ba>] local_bh_disable+0xb/0xd
     [<c06ab4e2>] _spin_lock_bh+0xb/0x16
     [<f8b6f600>] mkiss_receive_buf+0x2fb/0x3a6 [mkiss]
     [<c0572a30>] flush_to_ldisc+0xf7/0x198
     [<c0572b12>] tty_flip_buffer_push+0x41/0x51
     [<f89477f2>] ftdi_process_read+0x375/0x4ad [ftdi_sio]
     [<f8947a5a>] ftdi_read_bulk_callback+0x130/0x138 [ftdi_sio]
     [<c05d4bec>] usb_hcd_giveback_urb+0x63/0x93
     [<c05ea290>] uhci_giveback_urb+0xe5/0x15f
     [<c05eaabf>] uhci_scan_schedule+0x52e/0x767
     [<c05f6288>] ? psmouse_handle_byte+0xc/0xe5
     [<c054df78>] ? acpi_ev_gpe_detect+0xd6/0xe1
     [<c05ec5b0>] uhci_irq+0x110/0x125
     [<c05d4834>] usb_hcd_irq+0x40/0xa3
     [<c0465313>] handle_IRQ_event+0x2f/0x64
     [<c046642b>] handle_level_irq+0x74/0xbe
     [<c04663b7>] ? handle_level_irq+0x0/0xbe
     [<c0406e6e>] do_IRQ+0xc7/0xfe
     [<c0405668>] common_interrupt+0x28/0x30
     [<c056821a>] ? acpi_idle_enter_simple+0x162/0x19d
     [<c0617f52>] cpuidle_idle_call+0x60/0x92
     [<c0403c61>] cpu_idle+0x101/0x134
     [<c069b1ba>] rest_init+0x4e/0x50
     =======================
    ---[ end trace b7cc8076093467ad ]---
    ------------[ cut here ]------------
    WARNING: at kernel/softirq.c:136 _local_bh_enable_ip+0x3d/0xc4()
    [...]
    Pid: 0, comm: swapper Tainted: G        W 2.6.27.25-170.2.72.fc10.i686
     [<c042ddfb>] warn_on_slowpath+0x65/0x8b
     [<c06ab62b>] ? _spin_unlock_irqrestore+0x22/0x38
     [<c04228b4>] ? __enqueue_entity+0xe3/0xeb
     [<c042431e>] ? enqueue_entity+0x203/0x20b
     [<c0424361>] ? enqueue_task_fair+0x3b/0x3f
     [<c041f88c>] ? resched_task+0x3a/0x6e
     [<c06ab62b>] ? _spin_unlock_irqrestore+0x22/0x38
     [<c06ab4e2>] ? _spin_lock_bh+0xb/0x16
     [<f8b6f642>] ? mkiss_receive_buf+0x33d/0x3a6 [mkiss]
     [<c04325f9>] _local_bh_enable_ip+0x3d/0xc4
     [<c0432688>] local_bh_enable_ip+0x8/0xa
     [<c06ab54d>] _spin_unlock_bh+0x11/0x13
     [<f8b6f642>] mkiss_receive_buf+0x33d/0x3a6 [mkiss]
     [<c0572a30>] flush_to_ldisc+0xf7/0x198
     [<c0572b12>] tty_flip_buffer_push+0x41/0x51
     [<f89477f2>] ftdi_process_read+0x375/0x4ad [ftdi_sio]
     [<f8947a5a>] ftdi_read_bulk_callback+0x130/0x138 [ftdi_sio]
     [<c05d4bec>] usb_hcd_giveback_urb+0x63/0x93
     [<c05ea290>] uhci_giveback_urb+0xe5/0x15f
     [<c05eaabf>] uhci_scan_schedule+0x52e/0x767
     [<c05f6288>] ? psmouse_handle_byte+0xc/0xe5
     [<c054df78>] ? acpi_ev_gpe_detect+0xd6/0xe1
     [<c05ec5b0>] uhci_irq+0x110/0x125
     [<c05d4834>] usb_hcd_irq+0x40/0xa3
     [<c0465313>] handle_IRQ_event+0x2f/0x64
     [<c046642b>] handle_level_irq+0x74/0xbe
     [<c04663b7>] ? handle_level_irq+0x0/0xbe
     [<c0406e6e>] do_IRQ+0xc7/0xfe
     [<c0405668>] common_interrupt+0x28/0x30
     [<c056821a>] ? acpi_idle_enter_simple+0x162/0x19d
     [<c0617f52>] cpuidle_idle_call+0x60/0x92
     [<c0403c61>] cpu_idle+0x101/0x134
     [<c069b1ba>] rest_init+0x4e/0x50
     =======================
    ---[ end trace b7cc8076093467ad ]---
    mkiss: ax0: Trying crc-smack
    mkiss: ax0: Trying crc-flexnet
    
    The issue was, that the locking code in mkiss was assuming it was only
    ever being called in process or bh context.  Fixed by converting the
    involved locking code to use irq-safe locks.
    
    Review of other networking line disciplines shows that 6pack, both sync
    and async PPP and STRIP have similar issues.  The ppp_async one is the
    most interesting one as it sorts out half of the issue as far back as
    2004 in commit http://git.kernel.org/?p=linux/kernel/git/tglx/history.git;a=commitdiff;h=2996d8deaeddd01820691a872550dc0cfba0c37d
    
    Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
    Reported-by: Guido Trentalancia <guido@trentalancia.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 1551600..913a564 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -398,13 +398,14 @@ static DEFINE_RWLOCK(disc_data_lock);
                                                                                 
 static struct sixpack *sp_get(struct tty_struct *tty)
 {
+	unsigned long flags;
 	struct sixpack *sp;
 
-	read_lock(&disc_data_lock);
+	read_lock_irqsave(&disc_data_lock, flags);
 	sp = tty->disc_data;
 	if (sp)
 		atomic_inc(&sp->refcnt);
-	read_unlock(&disc_data_lock);
+	read_unlock_irqrestore(&disc_data_lock, flags);
 
 	return sp;
 }
@@ -688,12 +689,13 @@ out:
  */
 static void sixpack_close(struct tty_struct *tty)
 {
+	unsigned long flags;
 	struct sixpack *sp;
 
-	write_lock(&disc_data_lock);
+	write_lock_irqsave(&disc_data_lock, flags);
 	sp = tty->disc_data;
 	tty->disc_data = NULL;
-	write_unlock(&disc_data_lock);
+	write_unlock_irqrestore(&disc_data_lock, flags);
 	if (!sp)
 		return;
 
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index fda2fc8..a728650 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -244,15 +244,16 @@ static int kiss_esc_crc(unsigned char *s, unsigned char *d, unsigned short crc,
 /* Send one completely decapsulated AX.25 packet to the AX.25 layer. */
 static void ax_bump(struct mkiss *ax)
 {
+	unsigned long flags;
 	struct sk_buff *skb;
 	int count;
 
-	spin_lock_bh(&ax->buflock);
+	spin_lock_irqsave(&ax->buflock, flags);
 	if (ax->rbuff[0] > 0x0f) {
 		if (ax->rbuff[0] & 0x80) {
 			if (check_crc_16(ax->rbuff, ax->rcount) < 0) {
 				ax->dev->stats.rx_errors++;
-				spin_unlock_bh(&ax->buflock);
+				spin_unlock_irqrestore(&ax->buflock, flags);
 
 				return;
 			}
@@ -267,7 +268,7 @@ static void ax_bump(struct mkiss *ax)
 		} else if (ax->rbuff[0] & 0x20)  {
 			if (check_crc_flex(ax->rbuff, ax->rcount) < 0) {
 				ax->dev->stats.rx_errors++;
-				spin_unlock_bh(&ax->buflock);
+				spin_unlock_irqrestore(&ax->buflock, flags);
 				return;
 			}
 			if (ax->crcmode != CRC_MODE_FLEX && ax->crcauto) {
@@ -294,7 +295,7 @@ static void ax_bump(struct mkiss *ax)
 		printk(KERN_ERR "mkiss: %s: memory squeeze, dropping packet.\n",
 		       ax->dev->name);
 		ax->dev->stats.rx_dropped++;
-		spin_unlock_bh(&ax->buflock);
+		spin_unlock_irqrestore(&ax->buflock, flags);
 		return;
 	}
 
@@ -303,11 +304,13 @@ static void ax_bump(struct mkiss *ax)
 	netif_rx(skb);
 	ax->dev->stats.rx_packets++;
 	ax->dev->stats.rx_bytes += count;
-	spin_unlock_bh(&ax->buflock);
+	spin_unlock_irqrestore(&ax->buflock, flags);
 }
 
 static void kiss_unesc(struct mkiss *ax, unsigned char s)
 {
+	unsigned long flags;
+
 	switch (s) {
 	case END:
 		/* drop keeptest bit = VSV */
@@ -334,18 +337,18 @@ static void kiss_unesc(struct mkiss *ax, unsigned char s)
 		break;
 	}
 
-	spin_lock_bh(&ax->buflock);
+	spin_lock_irqsave(&ax->buflock, flags);
 	if (!test_bit(AXF_ERROR, &ax->flags)) {
 		if (ax->rcount < ax->buffsize) {
 			ax->rbuff[ax->rcount++] = s;
-			spin_unlock_bh(&ax->buflock);
+			spin_unlock_irqrestore(&ax->buflock, flags);
 			return;
 		}
 
 		ax->dev->stats.rx_over_errors++;
 		set_bit(AXF_ERROR, &ax->flags);
 	}
-	spin_unlock_bh(&ax->buflock);
+	spin_unlock_irqrestore(&ax->buflock, flags);
 }
 
 static int ax_set_mac_address(struct net_device *dev, void *addr)
@@ -367,6 +370,7 @@ static void ax_changedmtu(struct mkiss *ax)
 {
 	struct net_device *dev = ax->dev;
 	unsigned char *xbuff, *rbuff, *oxbuff, *orbuff;
+	unsigned long flags;
 	int len;
 
 	len = dev->mtu * 2;
@@ -392,7 +396,7 @@ static void ax_changedmtu(struct mkiss *ax)
 		return;
 	}
 
-	spin_lock_bh(&ax->buflock);
+	spin_lock_irqsave(&ax->buflock, flags);
 
 	oxbuff    = ax->xbuff;
 	ax->xbuff = xbuff;
@@ -423,7 +427,7 @@ static void ax_changedmtu(struct mkiss *ax)
 	ax->mtu      = dev->mtu + 73;
 	ax->buffsize = len;
 
-	spin_unlock_bh(&ax->buflock);
+	spin_unlock_irqrestore(&ax->buflock, flags);
 
 	kfree(oxbuff);
 	kfree(orbuff);
@@ -433,6 +437,7 @@ static void ax_changedmtu(struct mkiss *ax)
 static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 {
 	struct mkiss *ax = netdev_priv(dev);
+	unsigned long flags;
 	unsigned char *p;
 	int actual, count;
 
@@ -449,7 +454,7 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 
 	p = icp;
 
-	spin_lock_bh(&ax->buflock);
+	spin_lock_irqsave(&ax->buflock, flags);
 	if ((*p & 0x0f) != 0) {
 		/* Configuration Command (kissparms(1).
 		 * Protocol spec says: never append CRC.
@@ -479,7 +484,7 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 				ax->crcauto = (cmd ? 0 : 1);
 				printk(KERN_INFO "mkiss: %s: crc mode %s %d\n", ax->dev->name, (len) ? "set to" : "is", cmd);
 			}
-			spin_unlock_bh(&ax->buflock);
+			spin_unlock_irqrestore(&ax->buflock, flags);
 			netif_start_queue(dev);
 
 			return;
@@ -512,7 +517,7 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 			count = kiss_esc(p, (unsigned char *)ax->xbuff, len);
 		}
   	}
-	spin_unlock_bh(&ax->buflock);
+	spin_unlock_irqrestore(&ax->buflock, flags);
 
 	set_bit(TTY_DO_WRITE_WAKEUP, &ax->tty->flags);
 	actual = ax->tty->ops->write(ax->tty, ax->xbuff, count);
@@ -704,13 +709,14 @@ static DEFINE_RWLOCK(disc_data_lock);
 
 static struct mkiss *mkiss_get(struct tty_struct *tty)
 {
+	unsigned long flags;
 	struct mkiss *ax;
 
-	read_lock(&disc_data_lock);
+	read_lock_irqsave(&disc_data_lock, flags);
 	ax = tty->disc_data;
 	if (ax)
 		atomic_inc(&ax->refcnt);
-	read_unlock(&disc_data_lock);
+	read_unlock_irqrestore(&disc_data_lock, flags);
 
 	return ax;
 }
@@ -809,12 +815,13 @@ out:
 
 static void mkiss_close(struct tty_struct *tty)
 {
+	unsigned long flags;
 	struct mkiss *ax;
 
-	write_lock(&disc_data_lock);
+	write_lock_irqsave(&disc_data_lock, flags);
 	ax = tty->disc_data;
 	tty->disc_data = NULL;
-	write_unlock(&disc_data_lock);
+	write_unlock_irqrestore(&disc_data_lock, flags);
 
 	if (!ax)
 		return;
diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
index 17c116b..1fd319b 100644
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -132,13 +132,15 @@ static DEFINE_RWLOCK(disc_data_lock);
 
 static struct asyncppp *ap_get(struct tty_struct *tty)
 {
+	unsigned long flags;
 	struct asyncppp *ap;
 
-	read_lock(&disc_data_lock);
+	read_lock_irqsave(&disc_data_lock, flags);
 	ap = tty->disc_data;
 	if (ap != NULL)
 		atomic_inc(&ap->refcnt);
-	read_unlock(&disc_data_lock);
+	read_unlock_irqrestore(&disc_data_lock, flags);
+
 	return ap;
 }
 
@@ -215,12 +217,13 @@ ppp_asynctty_open(struct tty_struct *tty)
 static void
 ppp_asynctty_close(struct tty_struct *tty)
 {
+	unsigned long flags;
 	struct asyncppp *ap;
 
-	write_lock_irq(&disc_data_lock);
+	write_lock_irqsave(&disc_data_lock, flags);
 	ap = tty->disc_data;
 	tty->disc_data = NULL;
-	write_unlock_irq(&disc_data_lock);
+	write_unlock_irqrestore(&disc_data_lock, flags);
 	if (!ap)
 		return;
 
diff --git a/drivers/net/ppp_synctty.c b/drivers/net/ppp_synctty.c
index aa3d39f..1b3f75f 100644
--- a/drivers/net/ppp_synctty.c
+++ b/drivers/net/ppp_synctty.c
@@ -182,13 +182,15 @@ static DEFINE_RWLOCK(disc_data_lock);
 
 static struct syncppp *sp_get(struct tty_struct *tty)
 {
+	unsigned long flags;
 	struct syncppp *ap;
 
-	read_lock(&disc_data_lock);
+	read_lock_irqsave(&disc_data_lock, flags);
 	ap = tty->disc_data;
 	if (ap != NULL)
 		atomic_inc(&ap->refcnt);
-	read_unlock(&disc_data_lock);
+	read_unlock_irqrestore(&disc_data_lock, flags);
+
 	return ap;
 }
 
@@ -262,12 +264,13 @@ ppp_sync_open(struct tty_struct *tty)
 static void
 ppp_sync_close(struct tty_struct *tty)
 {
+	unsigned long flags;
 	struct syncppp *ap;
 
-	write_lock_irq(&disc_data_lock);
+	write_lock_irqsave(&disc_data_lock, flags);
 	ap = tty->disc_data;
 	tty->disc_data = NULL;
-	write_unlock_irq(&disc_data_lock);
+	write_unlock_irqrestore(&disc_data_lock, flags);
 	if (!ap)
 		return;
 
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 38366a5..3d39f65 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -856,6 +856,7 @@ static int strip_change_mtu(struct net_device *dev, int new_mtu)
 	unsigned char *orbuff = strip_info->rx_buff;
 	unsigned char *osbuff = strip_info->sx_buff;
 	unsigned char *otbuff = strip_info->tx_buff;
+	unsigned long flags;
 
 	if (new_mtu > MAX_SEND_MTU) {
 		printk(KERN_ERR
@@ -864,11 +865,11 @@ static int strip_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 	}
 
-	spin_lock_bh(&strip_lock);
+	spin_lock_irqsave(&strip_lock, flags);
 	if (!allocate_buffers(strip_info, new_mtu)) {
 		printk(KERN_ERR "%s: unable to grow strip buffers, MTU change cancelled.\n",
 		       strip_info->dev->name);
-		spin_unlock_bh(&strip_lock);
+		spin_unlock_irqrestore(&strip_lock, flags);
 		return -ENOMEM;
 	}
 
@@ -892,7 +893,7 @@ static int strip_change_mtu(struct net_device *dev, int new_mtu)
 		}
 	}
 	strip_info->tx_head = strip_info->tx_buff;
-	spin_unlock_bh(&strip_lock);
+	spin_unlock_irqrestore(&strip_lock, flags);
 
 	printk(KERN_NOTICE "%s: strip MTU changed fom %d to %d.\n",
 	       strip_info->dev->name, old_mtu, strip_info->mtu);
@@ -983,10 +984,13 @@ static void strip_seq_neighbours(struct seq_file *seq,
 			   const MetricomNodeTable * table,
 			   const char *title)
 {
-	/* We wrap this in a do/while loop, so if the table changes */
-	/* while we're reading it, we just go around and try again. */
+	unsigned long flags;
 	struct timeval t;
 
+	/*
+	 * We wrap this in a do/while loop, so if the table changes
+	 * while we're reading it, we just go around and try again.
+	 */
 	do {
 		int i;
 		t = table->timestamp;
@@ -995,9 +999,9 @@ static void strip_seq_neighbours(struct seq_file *seq,
 		for (i = 0; i < table->num_nodes; i++) {
 			MetricomNode node;
 
-			spin_lock_bh(&strip_lock);
+			spin_lock_irqsave(&strip_lock, flags);
 			node = table->node[i];
-			spin_unlock_bh(&strip_lock);
+			spin_unlock_irqrestore(&strip_lock, flags);
 			seq_printf(seq, "  %s\n", node.c);
 		}
 	} while (table->timestamp.tv_sec != t.tv_sec
@@ -1536,6 +1540,7 @@ static void strip_send(struct strip *strip_info, struct sk_buff *skb)
 static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct strip *strip_info = netdev_priv(dev);
+	unsigned long flags;
 
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "%s: xmit call when iface is down\n",
@@ -1574,11 +1579,11 @@ static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
 			       strip_info->dev->name, sx_pps_count / 8);
 	}
 
-	spin_lock_bh(&strip_lock);
+	spin_lock_irqsave(&strip_lock, flags);
 
 	strip_send(strip_info, skb);
 
-	spin_unlock_bh(&strip_lock);
+	spin_unlock_irqrestore(&strip_lock, flags);
 
 	if (skb)
 		dev_kfree_skb(skb);
@@ -2263,12 +2268,13 @@ static void strip_receive_buf(struct tty_struct *tty, const unsigned char *cp,
 {
 	struct strip *strip_info = tty->disc_data;
 	const unsigned char *end = cp + count;
+	unsigned long flags;
 
 	if (!strip_info || strip_info->magic != STRIP_MAGIC
 	    || !netif_running(strip_info->dev))
 		return;
 
-	spin_lock_bh(&strip_lock);
+	spin_lock_irqsave(&strip_lock, flags);
 #if 0
 	{
 		struct timeval tv;
@@ -2335,7 +2341,7 @@ static void strip_receive_buf(struct tty_struct *tty, const unsigned char *cp,
 		}
 		cp++;
 	}
-	spin_unlock_bh(&strip_lock);
+	spin_unlock_irqrestore(&strip_lock, flags);
 }
 
 
@@ -2523,9 +2529,11 @@ static void strip_dev_setup(struct net_device *dev)
 
 static void strip_free(struct strip *strip_info)
 {
-	spin_lock_bh(&strip_lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&strip_lock, flags);
 	list_del_rcu(&strip_info->list);
-	spin_unlock_bh(&strip_lock);
+	spin_unlock_irqrestore(&strip_lock, flags);
 
 	strip_info->magic = 0;
 
@@ -2539,6 +2547,7 @@ static void strip_free(struct strip *strip_info)
 static struct strip *strip_alloc(void)
 {
 	struct list_head *n;
+	unsigned long flags;
 	struct net_device *dev;
 	struct strip *strip_info;
 
@@ -2562,7 +2571,7 @@ static struct strip *strip_alloc(void)
 	strip_info->idle_timer.function = strip_IdleTask;
 
 
-	spin_lock_bh(&strip_lock);
+	spin_lock_irqsave(&strip_lock, flags);
  rescan:
 	/*
 	 * Search the list to find where to put our new entry
@@ -2581,7 +2590,7 @@ static struct strip *strip_alloc(void)
 	sprintf(dev->name, "st%ld", dev->base_addr);
 
 	list_add_tail_rcu(&strip_info->list, &strip_list);
-	spin_unlock_bh(&strip_lock);
+	spin_unlock_irqrestore(&strip_lock, flags);
 
 	return strip_info;
 }

