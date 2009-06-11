From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Thu, 11 Jun 2009 13:44:36 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0906111333100.31536@xanadu.home>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>
 <1244732090.2785.12.camel@achroite>
 <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
 <1244739166.2785.52.camel@achroite>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: mfuzzey@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:12355 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbZFKRoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 13:44:54 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR005.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KL3005ED4S0SD11@VL-MO-MR005.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 11 Jun 2009 13:33:37 -0400 (EDT)
In-reply-to: <1244739166.2785.52.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2009, Ben Hutchings wrote:

> On Thu, 2009-06-11 at 12:22 -0400, Nicolas Pitre wrote:
> > On Thu, 11 Jun 2009, Ben Hutchings wrote:
> > 
> > > On Thu, 2009-06-11 at 08:47 +0200, Martin Fuzzey wrote:
> > > > Ben Hutchings wrote:
> > > > > Who needs this feature?  Why not use ethtool in an initramfs?
> > > > >
> > > > >   
> > > > > Forcing speed and duplex is occasionally needed to work around a link
> > > > > partner that doesn't implement autonegotiation correctly.  I don't see
> > > > > that it should ever be needed in platform configuration.  If the driver
> > > > > doesn't detect the MAC/PHY capabilities correctly then the driver should
> > > > > be fixed.  Overriding the settings once will not prevent an unsupported
> > > > > mode being selected later.
> > > > >
> > > > >   
> > > > To summarize the recent points I made in the smc91x: forcing speed thread :
> > > > 
> > > > 1) Setting up and maintaining an initramfs can increase the complexity
> > > > for embedded systems - it's another image file to build, distribute,
> > > > update to bootloader etc.
> > > 
> > > This doesn't seem like a huge burden if you're net-booting.  And if
> > > you're not net-booting, it's not critical that you override the link
> > > mode immediately; you can do it in the regular init scripts.
> > 
> > Sure... But for some embedded setup this is actually more trouble and 
> > hassle than having a non-intrusive kernel based facility that can set 
> > defaults for you.
> 
> Doing it in an init script is even less intrusive!  But it seems that
> the ethtool API doesn't do what you need in this case, anyway.

Stop thinking in terms of workstation setups please.

[...]
> It's an example of providing a generic solution, which is definitely
> more than a quick hack, but I don't see it as a "clean solution" for the
> problem that certain link modes don't work on a particular board.  A
> clean solution would disable those modes altogether in the driver.

And now you are considering the addition of special restrictions for 
some special hardware directly into the driver as less intrusive than 
what is being proposed?  And now imagine what this would look like after 
56 different embedded designs have added their own kirks into the 
driver.. because, yes, in the embedded world you do have much more than 
56 different designs sharing the same driver but each with their own 
flaws.

What people are hacking now is some #if 0 ... #endif in their own tree 
to disable the initialization of driver features that their hardware is 
not able to cope with.  There are two cleaner alternatives: changing the 
default with ethtool from user space, or using a kernel based 
ethtool-like facility to do the same as conveniently as 
CONFIG_IP_PNP_DHCP is doing already for IP autoconfig.  The later is 
what this proposal is about.


Nicolas
