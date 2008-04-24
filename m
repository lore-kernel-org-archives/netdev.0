From: Brad Boyer <flar@allandria.com>
Subject: Re: [patch 10/15] m68k: Some network drivers do not check the platform
Date: Thu, 24 Apr 2008 10:54:49 -0700
Message-ID: <20080424175449.GA20639@cynthia.pants.nu>
References: <20080424182940.424312704@mail.of.borg> <20080424183242.943446357@mail.of.borg> <20080424184256.GA8531@infradead.org> <Pine.LNX.4.64.0804242045510.21224@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-76-245-85-235.dsl.pltn13.sbcglobal.net ([76.245.85.235]:36340
	"EHLO cynthia.pants.nu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbYDXVtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 17:49:53 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804242045510.21224@anakin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 08:51:17PM +0200, Geert Uytterhoeven wrote:
> On Thu, 24 Apr 2008, Christoph Hellwig wrote:
> > On Thu, Apr 24, 2008 at 08:29:50PM +0200, Geert Uytterhoeven wrote:
> > > +++ b/drivers/net/macmace.c
> > > @@ -781,6 +781,9 @@ static int __init mac_mace_init_module(v
> > >  {
> > >  	int err;
> > >  
> > > +	if (!MACH_IS_MAC)
> > > +		return -ENODEV;
> > > +
> > >  	if ((err = platform_driver_register(&mac_mace_driver))) {
> > >  		printk(KERN_ERR "Driver registration failed\n");
> > >  		return err;
> > 
> 
> All these drivers predate the platform device framework and have been converted
> to this framework a while ago, without separating the actual platform drivers
> and platform devices.

At some point I intend to merge macmace.c into mace.c by using the macio
bus code on m68k macs. This would avoid the need for these checks, but
it's not something I have working yet. My first driver to merge with ppc
would be serial since we don't need any DMA support for that. It's on my
list of things to do once I get macio working on m68k. I'll be sure to
send a patch to the m68k list as soon as I have something that runs.
After that I'll copy it to the ppc list to make sure I didn't break that,
and submit it for inclusion once people are satisfied.

	Brad Boyer
	flar@allandria.com

