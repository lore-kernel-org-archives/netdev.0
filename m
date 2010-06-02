From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: 64-bit net_device_stats
Date: Thu, 3 Jun 2010 01:38:16 +0200
Message-ID: <201006030138.17668.arnd@arndb.de>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com> <1275514469.2115.70.camel@achroite.uk.solarflarecom.com> <20100602145912.56ef62c2@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, junchangwang@gmail.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:63957 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933314Ab0FBXi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 19:38:26 -0400
In-Reply-To: <20100602145912.56ef62c2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 02 June 2010 23:59:12 Stephen Hemminger wrote:
> On Wed, 02 Jun 2010 22:34:29 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > Changing the counter types to u64 for 32-bit architectures would remove
> > atomicity and expose half-updated counters to userland.  Changing the
> > driver interface significantly so that atomicity is not needed would
> > require changes to hundreds of drivers.
> 
> Another big issue is maintaining ABI compatibility for /proc and ioctl
> interfaces. So bigger values would only be available through netlink,
> and most applications using counters don't use netlink. 

Doesn't the /proc interface already allow 64 bit values in case of
64 bit hosts running the same 32 bit user space?

For the ioctl interfaces, we can of course introduce additional
ioctl commands that always deal with 64 bit values, many other
subsystems have been extended in similar ways.

We don't mandate that a program built against new kernel headers
must work on old kernels, so it is possibly to actually change
the definitions, as long as the kernel still supports the old
interfaces for existing binaries. We should still have a
good reason even for breaking the ABI in ways that we don't
guarantee to be stable.

	Arnd
