From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: sis190 build breakage
Date: Tue, 29 Jan 2008 16:42:09 -0800
Message-ID: <20080129164209.72b8982b.rdunlap@xenotime.net>
References: <20080129215023.GA24152@stro.at>
	<20080129220310.GC15445@electric-eye.fr.zoreil.com>
	<20080129222719.GS1446@baikonur.stro.at>
	<20080129222748.GD15445@electric-eye.fr.zoreil.com>
	<20080129231223.GT1446@baikonur.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	samr <sam@ravnborg.org>
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:52657 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752355AbYA3AmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 19:42:18 -0500
Received: from midway.site ([71.245.106.199]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 16:42:09 -0800
In-Reply-To: <20080129231223.GT1446@baikonur.stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jan 2008 00:12:23 +0100 maximilian attems wrote:

> On Tue, Jan 29, 2008 at 11:27:48PM +0100, Francois Romieu wrote:
> > maximilian attems <max@stro.at> :
> > [...]
> > > probably i should to get interesting info.
> > 
> > Don't bother.
> > 
> > $ less +/devinitdata Documentation/pci.txt
> > [...]
> > Tips on when/where to use the above attributes:
> >         o The module_init()/module_exit() functions (and all
> >           initialization functions called _only_ from these)
> >           should be marked __init/__exit.
> > 
> >         o Do not mark the struct pci_driver.
> > 
> >         o The ID table array should be marked __devinitdata.
> >
> > Could our documentation be wrong ?
> 
> yep that was what i had in mind, so i was a bit baffled..
> 
> randy any insight?

Hi,

I can't reproduce the problem... :(

I tend to expect something with Sam's new section mismatch detection.
Maybe it's a lot better and found a real issue, but AFAIK this table
can still be marked as __devinitdata.

Sam cc-ed.


> > 
> > diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
> > index b570402..2e9e88b 100644
> > --- a/drivers/net/sis190.c
> > +++ b/drivers/net/sis190.c
> > @@ -326,7 +326,7 @@ static const struct {
> >  	{ "SiS 191 PCI Gigabit Ethernet adapter" },
> >  };
> >  
> > -static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
> > +static struct pci_device_id sis190_pci_tbl[] = {
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
> >  	{ 0, },
> 
> thanks for quick fix.

---
~Randy
