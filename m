From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: Compex FreedomLine 32 PnP-PCI2 broken with de2104x
Date: Mon, 25 Feb 2008 00:15:06 -0700
Message-ID: <20080225071505.GC26674@colo.lackof.org>
References: <200801262158.12016.linux@rainbow-software.org> <200801302123.07783.linux@rainbow-software.org> <20080218032111.GA7970@colo.lackof.org> <200802181740.44196.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>, jgarzik@pobox.com,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:54555 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758AbYBYHPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 02:15:32 -0500
Content-Disposition: inline
In-Reply-To: <200802181740.44196.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2008 at 05:40:42PM +0100, Ondrej Zary wrote:
> On Monday 18 February 2008 04:21:11 Grant Grundler wrote:
> > On Wed, Jan 30, 2008 at 09:23:06PM +0100, Ondrej Zary wrote:
> > > On Saturday 26 January 2008 21:58:10 Ondrej Zary wrote:
> > > > Hello,
> > > > I was having problems with these FreedomLine cards with Linux before
> > > > but tested it thoroughly today. This card uses DEC 21041 chip and has
> > > > TP and BNC connectors:
> > > >
> > > > 00:12.0 Ethernet controller [0200]: Digital Equipment Corporation
> > > > DECchip 21041 [Tulip Pass 3] [1011:0014] (rev 21)
> > > >
> > > >
> > > > de2104x driver was loaded automatically by udev and card seemed to
> > > > work. Until I disconnected the TP cable and putting it back after a
> > > > while. The driver then switched to (non-existing) AUI port and remained
> > > > there. I tried to set media to TP using ethtool - and the whole kernel
> > > > crashed because of BUG_ON(de_is_running(de));
> > > > in de_set_media(). Seems that the driver is unable to stop the DMA in
> > > > de_stop_rxtx().
> >
> > The BUG_ON() is probably fine normally. But the media selection sounds
> > broken. It's possible to select the wrong media type with 21040 chip but
> > shouldn't be possible with 21041. For 21040 support, see
> > de21040_get_media_info(). But de21041_get_srom_info() is expected to
> > determine which media
> > types are supported from SEPROM "media blocks".   My guess is that code
> > is broken since it seems to work with de405 driver. If you care to
> > work the difference, I'd be happy to make a patch to fix that up.
> 
> I don't think that BUG_ON() should be there. It should probably printk a 
> warning but certainly not crash the whole machine.

Ah ok - I agree. I'll see if we can fail more gracfully there.
If you have an idea already, please send me a patch.

> > > > Then I found that there's de4x5 driver which supports the same cards as
> > > > de2104x (and some other too) - and this one works fine! I can plug and
> > > > unplug the cable and even change between TP and BNC ports just by
> > > > unplugging one and plugging the other cable in. Unfortunately, this
> > > > driver is blacklisted by default - at least in Slackware and Debian.
> >
> > ISTR there was a time when tulip would compete with de4x5 for devices.
> > tulip is the preferred driver. That's clearly no longer the case
> > and perhaps both distro's need to revisit this.
> 
> de4x5 has no MODULE_DEVICE_TABLE for PCI devices anymore, so no conflicts. 
> That's probably good for cards that work with tulip driver but bad for mine 
> card and also probably for some other cards that (should) work with de2104x.
> 
> >
> > > > The question is: why does de2104x exist? Does it work better with some
> > > > hardware?
> >
> > de2104x is a "work in progress".
> > That's why it's marked "EXPERIMENTAL" in the Kconfig file.
> 
> Great, it looks to be 6 years old and it's still experimental. Probably 
> because it never worked properly.

Yeah, probably.

> I think that de2104x driver should be removed (or at least its 
> MODULE_DEVICE_TABLE) and MODULE_DEVICE_TABLE with only 21040 and 21041 PCI 
> IDs added to de4x5.
> 
> I can send a patch if this is acceptable.

It's acceptable to me. Jeff? (jgarzik)

thanks,
grant
