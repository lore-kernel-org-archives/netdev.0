From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [3.5 regression / mcs7830 / bisected] bridge constantly toggeling between disabled and forwarding
Date: Tue, 9 Oct 2012 09:21:31 +0200
Message-ID: <201210090921.31415.linux@rainbow-software.org>
References: <20120723091504.2d035d28@xenia.leun.net> <20120927173905.GC21025@kroah.com> <20121009071515.607f85a4@xenia.leun.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Leun <lkml20120218@newton.leun.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121009071515.607f85a4@xenia.leun.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 October 2012, Michael Leun wrote:
> On Thu, 27 Sep 2012 10:39:05 -0700
>
> Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Tue, Jul 24, 2012 at 01:36:34AM +0200, Michael Leun wrote:
> > > On Mon, 23 Jul 2012 09:15:04 +0200
> > > Michael Leun <lkml20120218@newton.leun.net> wrote:
> > >
> > > [see issue description below]
> > >
> > > Bisecting yielded
> > >
> > > b1ff4f96fd1c63890d78d8939c6e0f2b44ce3113 is the first bad commit
> > > commit b1ff4f96fd1c63890d78d8939c6e0f2b44ce3113
> > > Author: Ondrej Zary <linux@rainbow-software.org>
> > > Date:   Fri Jun 1 10:29:08 2012 +0000
> > >
> > >     mcs7830: Implement link state detection
> > >
> > >     Add .status callback that detects link state changes.
> > >     Tested with MCS7832CV-AA chip (9710:7830, identified as rev.C
> > > by the driver). Fixes
> > > https://bugzilla.kernel.org/show_bug.cgi?id=28532
> > >
> > >     Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> > >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > >
> > > :040000 040000 5480780cb5e75c57122a621fc3bab0108c16be27
> > >
> > > d97efd9cc0a465dff76bcd3a3c547f718f2a5345 M    drivers
> > >
> > >
> > > Reverting that from 3.5 makes the issue go away.
> >
> > Did this ever get resolved in 3.6-rc7 or any older kernel?  I can't
> > revert the patch from 3.5.y unless it's also fixed in Linus's tree.
>
> Please excuse me for answering a bit late.
>
> No, that never got resolved, I still have the problem with 3.6 but I'm
> not shure about the correct solution.
>
> Maybe link state detection just does not work with some of that devices
> and we should have an possibility to enable/disable it per device,
> maybe it can be handeled with an blacklist of not working devices,
> maybe it could be fixed - I do not know and also do not know how to
> find out.
>
> But I'm willing to test.

Can you please apply this debug patch and provide the output?

--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -638,6 +638,7 @@ static void mcs7830_status(struct usbnet *dev, struct urb *urb)
 		return;
 
 	link = !(buf[1] & 0x20);
+	printk("netif_carrier_ok=%d, link=%d, buf[0]=0x%02x, buf[1]=0x%02x\n", netif_carrier_ok(dev->net), link, buf[0], buf[1]);
 	if (netif_carrier_ok(dev->net) != link) {
 		if (link) {
 			netif_carrier_on(dev->net);


-- 
Ondrej Zary
