From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Thu, 11 Jun 2009 15:08:23 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0906111452340.31536@xanadu.home>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>
 <1244732090.2785.12.camel@achroite>
 <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
 <1244739166.2785.52.camel@achroite>
 <alpine.LFD.2.00.0906111333100.31536@xanadu.home>
 <1244744967.2785.61.camel@achroite>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_wz6EuaQ2liYxhG7LXKPTYw)"
Cc: mfuzzey@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:57837 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758656AbZFKTIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 15:08:38 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR005.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KL300EF28NNXOY0@VL-MO-MR005.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 11 Jun 2009 14:57:24 -0400 (EDT)
In-reply-to: <1244744967.2785.61.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--Boundary_(ID_wz6EuaQ2liYxhG7LXKPTYw)
Content-type: TEXT/PLAIN; charset=UTF-8
Content-transfer-encoding: 8BIT

On Thu, 11 Jun 2009, Ben Hutchings wrote:

> On Thu, 2009-06-11 at 13:44 -0400, Nicolas Pitre wrote:
> > On Thu, 11 Jun 2009, Ben Hutchings wrote:
> > 
> > > On Thu, 2009-06-11 at 12:22 -0400, Nicolas Pitre wrote:
> > > > On Thu, 11 Jun 2009, Ben Hutchings wrote:
> > > > 
> > > > > On Thu, 2009-06-11 at 08:47 +0200, Martin Fuzzey wrote:
> > > > > > Ben Hutchings wrote:
> > > > > > > Who needs this feature?  Why not use ethtool in an initramfs?
> > > > > > >
> > > > > > >   
> > > > > > > Forcing speed and duplex is occasionally needed to work around a link
> > > > > > > partner that doesn't implement autonegotiation correctly.  I don't see
> > > > > > > that it should ever be needed in platform configuration.  If the driver
> > > > > > > doesn't detect the MAC/PHY capabilities correctly then the driver should
> > > > > > > be fixed.  Overriding the settings once will not prevent an unsupported
> > > > > > > mode being selected later.
> > > > > > >
> > > > > > >   
> > > > > > To summarize the recent points I made in the smc91x: forcing speed thread :
> > > > > > 
> > > > > > 1) Setting up and maintaining an initramfs can increase the complexity
> > > > > > for embedded systems - it's another image file to build, distribute,
> > > > > > update to bootloader etc.
> > > > > 
> > > > > This doesn't seem like a huge burden if you're net-booting.  And if
> > > > > you're not net-booting, it's not critical that you override the link
> > > > > mode immediately; you can do it in the regular init scripts.
> > > > 
> > > > Sure... But for some embedded setup this is actually more trouble and 
> > > > hassle than having a non-intrusive kernel based facility that can set 
> > > > defaults for you.
> > > 
> > > Doing it in an init script is even less intrusive!  But it seems that
> > > the ethtool API doesn't do what you need in this case, anyway.
> > 
> > Stop thinking in terms of workstation setups please.
> 
> Maybe you should stop thinking that an embedded system has to do things
> entirely differently?

Sorry, but like it or not, embedded systems are different.

> Please note, I'm talking about an init script -
> which you surely must have - not an initramfs, which I recognise is
> optional and unnecessary for most embedded systems.

An init script is already a luxury for some systems.  It means a 
script, which implies a shell, and of course the tool binaries (ethtool 
in this case) to be called by your shell.  Not only those do bloat your 
system (the shell + tool + script occupies way more space than the 
proposed module) and then you do have to maintain those components as 
well, but it also has impact on boot time.  Remember that we're not 
talking about systems bragging about their boot time being under 20 
seconds here, but systems that need to be operational in only a couple 
miliseconds.

> ﻿I was thinking that you could add it to the platform data for such
> devices, not that you would put board-specific quirks in the drivers.

And what if the majority of users for a driver simply don't need such a 
thing?  And how do you do that if the driver you need is for a PCI 
device?  And why would driver specific kirks be better than a generic 
module that can handle those params in a uniform way across all drivers?  
Especially if you can ignore said module if you don't need/want to use 
it?


Nicolas

--Boundary_(ID_wz6EuaQ2liYxhG7LXKPTYw)--
