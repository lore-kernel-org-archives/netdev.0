From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Thu, 11 Jun 2009 12:22:59 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>
 <1244732090.2785.12.camel@achroite>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: mfuzzey@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:39007 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbZFKQXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 12:23:17 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KL3008C41IBBTP0@VL-MH-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 11 Jun 2009 12:22:59 -0400 (EDT)
In-reply-to: <1244732090.2785.12.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2009, Ben Hutchings wrote:

> On Thu, 2009-06-11 at 08:47 +0200, Martin Fuzzey wrote:
> > Ben Hutchings wrote:
> > > Who needs this feature?  Why not use ethtool in an initramfs?
> > >
> > >   
> > > Forcing speed and duplex is occasionally needed to work around a link
> > > partner that doesn't implement autonegotiation correctly.  I don't see
> > > that it should ever be needed in platform configuration.  If the driver
> > > doesn't detect the MAC/PHY capabilities correctly then the driver should
> > > be fixed.  Overriding the settings once will not prevent an unsupported
> > > mode being selected later.
> > >
> > >   
> > To summarize the recent points I made in the smc91x: forcing speed thread :
> > 
> > 1) Setting up and maintaining an initramfs can increase the complexity
> > for embedded systems - it's another image file to build, distribute,
> > update to bootloader etc.
> 
> This doesn't seem like a huge burden if you're net-booting.  And if
> you're not net-booting, it's not critical that you override the link
> mode immediately; you can do it in the regular init scripts.

Sure... But for some embedded setup this is actually more trouble and 
hassle than having a non-intrusive kernel based facility that can set 
defaults for you.

The same way that the kernel currently has BOOTP and DHCP in the kernel.  
This is not necessarily the preferred way on a server or workstation, 
but damn useful on some embedded targets.  If DHCP and NFS root were 
removed from the kernel then of course using ethtool from some initramfs 
(along with dhclient and 'mount -t nfs') or the like would actually be 
the "right" way.  But CONFIG_IP_PNP_DHCP and CONFIG_ROOT_NFS are still 
in the kernel and unlikely to be removed soon.

> > I currently have this situation on one of my boards - 100Mbps doesn't
> > work due to electrical issues (bad routing).
> > This board is already in the wild - if it is fixed one day it will be a
> > new hardware revision and the code will have to cope with both.
> > Sure the "right" way is to fix the hardware but that's not always
> > economically or logistically possible.
> > I suspect such situations are not uncommon in the embedded world.
> 
> So, as I thought, you actually want to disable some modes completely.
> That is not what ethtool does.

No.  What is needed is to enforce a different _default_.  If someone 
manages to run ethtool after the system is booted and select the broken 
mode then that's just too bad.

Now the mainline people are (rightly) complaining that the 
embedded people don't participate enough and communicate their needs 
with the upstream kernel.  I think this is a good example from the 
embedded world providing a clean solution to a recurring issue which 
would return again to quick hacks if the mainline reception is 
"use a cramfs" again.


Nicolas
