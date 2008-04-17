From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Thu, 17 Apr 2008 14:15:06 +0200
Message-ID: <200804171415.07777.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com> <200804152046.44018.oliver@neukum.org> <20080415190030.GB27608@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Filip Aben <f.aben@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:35923 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbYDQMGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 08:06:06 -0400
In-Reply-To: <20080415190030.GB27608@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 15. April 2008 21:00:30 schrieb Greg KH:
> On Tue, Apr 15, 2008 at 08:46:42PM +0200, Oliver Neukum wrote:
> > Am Dienstag, 15. April 2008 17:34:08 schrieb Greg KH:
> > > So I'll go delete that "special" ioctl, that's not a good thing to do,
> > > use the common interfaces that all USB devices rely on instead, don't do
> > > something different for just one type of USB device.
> > 
> > Do you have a new unified patch? I'd work against that, lest we get
> > merge troubles.
> 
> Good idea :)
> 
> Here it is.

Another one.

As autosuspend is by default disabled, it makes no sense to have a module
parameter disabling it. Just don't enable it.

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oneukum@suse.de>

---

--- linux-2.6.25hso/drivers/net/usb/hso.c.alt	2008-04-17 14:00:09.000000000 +0200
+++ linux-2.6.25hso/drivers/net/usb/hso.c	2008-04-17 14:01:43.000000000 +0200
@@ -400,7 +400,6 @@ static int debug;
 static int procfs = 1;
 static int tty_major;
 static int disable_net;
-static int enable_autopm;
 
 /* driver info */
 static const char driver_name[] = "hso";
@@ -555,9 +554,6 @@ static int hso_proc_options(char *buf, c
 	len +=
 	    snprintf(buf + len, count - len, "tty_major: 0x%02x\n", tty_major);
 	len +=
-	    snprintf(buf + len, count - len, "enable_autopm: 0x%02x\n",
-		     enable_autopm);
-	len +=
 	    snprintf(buf + len, count - len, "disable_net: 0x%02x\n",
 		     disable_net);
 	return len;
@@ -2718,11 +2714,6 @@ static int hso_probe(struct usb_interfac
 	/* save our data pointer in this device */
 	usb_set_intfdata(interface, hso_dev);
 
-	if (enable_autopm == 0) {
-		usb_autopm_get_interface(hso_dev->interface);
-		hso_dev->suspend_disabled = 1;
-	}
-
 	/* done */
 	return 0;
 
@@ -3213,8 +3204,3 @@ module_param(tty_major, int, S_IRUGO | S
 /* set the major tty number (eg: insmod hso.ko tty_major=245) */
 MODULE_PARM_DESC(disable_net, "Disable the network interface");
 module_param(disable_net, int, S_IRUGO | S_IWUSR);
-
-/* enable autosuspend (default disabled) (eg: insmod hso.ko enable_autopm=1) */
-MODULE_PARM_DESC(enable_autopm,
-		 "Enable the auto power managment (autosuspend)");
-module_param(enable_autopm, int, S_IRUGO | S_IWUSR);

