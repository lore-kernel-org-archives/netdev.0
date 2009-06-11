From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
	configuration.
Date: Thu, 11 Jun 2009 17:52:46 +0100
Message-ID: <1244739166.2785.52.camel@achroite>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
	 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>
	 <1244732090.2785.12.camel@achroite>
	 <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mfuzzey@gmail.com, netdev@vger.kernel.org
To: Nicolas Pitre <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:43509 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753397AbZFKQwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 12:52:49 -0400
In-Reply-To: <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-06-11 at 12:22 -0400, Nicolas Pitre wrote:
> On Thu, 11 Jun 2009, Ben Hutchings wrote:
> 
> > On Thu, 2009-06-11 at 08:47 +0200, Martin Fuzzey wrote:
> > > Ben Hutchings wrote:
> > > > Who needs this feature?  Why not use ethtool in an initramfs?
> > > >
> > > >   
> > > > Forcing speed and duplex is occasionally needed to work around a link
> > > > partner that doesn't implement autonegotiation correctly.  I don't see
> > > > that it should ever be needed in platform configuration.  If the driver
> > > > doesn't detect the MAC/PHY capabilities correctly then the driver should
> > > > be fixed.  Overriding the settings once will not prevent an unsupported
> > > > mode being selected later.
> > > >
> > > >   
> > > To summarize the recent points I made in the smc91x: forcing speed thread :
> > > 
> > > 1) Setting up and maintaining an initramfs can increase the complexity
> > > for embedded systems - it's another image file to build, distribute,
> > > update to bootloader etc.
> > 
> > This doesn't seem like a huge burden if you're net-booting.  And if
> > you're not net-booting, it's not critical that you override the link
> > mode immediately; you can do it in the regular init scripts.
> 
> Sure... But for some embedded setup this is actually more trouble and 
> hassle than having a non-intrusive kernel based facility that can set 
> defaults for you.

Doing it in an init script is even less intrusive!  But it seems that
the ethtool API doesn't do what you need in this case, anyway.

[...]
> > > I currently have this situation on one of my boards - 100Mbps doesn't
> > > work due to electrical issues (bad routing).
> > > This board is already in the wild - if it is fixed one day it will be a
> > > new hardware revision and the code will have to cope with both.
> > > Sure the "right" way is to fix the hardware but that's not always
> > > economically or logistically possible.
> > > I suspect such situations are not uncommon in the embedded world.
> > 
> > So, as I thought, you actually want to disable some modes completely.
> > That is not what ethtool does.
> 
> No.  What is needed is to enforce a different _default_.  If someone 
> manages to run ethtool after the system is booted and select the broken 
> mode then that's just too bad.
>
> Now the mainline people are (rightly) complaining that the 
> embedded people don't participate enough and communicate their needs 
> with the upstream kernel  I think this is a good example from the 
> embedded world providing a clean solution to a recurring issue which 
> would return again to quick hacks if the mainline reception is 
> "use a cramfs" again.

It's an example of providing a generic solution, which is definitely
more than a quick hack, but I don't see it as a "clean solution" for the
problem that certain link modes don't work on a particular board.  A
clean solution would disable those modes altogether in the driver.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

