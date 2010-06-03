From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 64-bit net_device_stats
Date: Thu, 03 Jun 2010 15:51:07 +0100
Message-ID: <1275576667.2106.11.camel@achroite.uk.solarflarecom.com>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
	 <1275514469.2115.70.camel@achroite.uk.solarflarecom.com>
	 <20100602145912.56ef62c2@nehalam>  <201006030138.17668.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, junchangwang@gmail.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53968 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755139Ab0FCOvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 10:51:11 -0400
In-Reply-To: <201006030138.17668.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-03 at 01:38 +0200, Arnd Bergmann wrote:
> On Wednesday 02 June 2010 23:59:12 Stephen Hemminger wrote:
> > On Wed, 02 Jun 2010 22:34:29 +0100
> > Ben Hutchings <bhutchings@solarflare.com> wrote:
> > 
> > > Changing the counter types to u64 for 32-bit architectures would remove
> > > atomicity and expose half-updated counters to userland.  Changing the
> > > driver interface significantly so that atomicity is not needed would
> > > require changes to hundreds of drivers.
> > 
> > Another big issue is maintaining ABI compatibility for /proc and ioctl
> > interfaces. So bigger values would only be available through netlink,
> > and most applications using counters don't use netlink. 
> 
> Doesn't the /proc interface already allow 64 bit values in case of
> 64 bit hosts running the same 32 bit user space?

Yes.  And the most widely used consumer of /proc/net/dev, ifconfig,
already parses them as 64-bit values.

> For the ioctl interfaces, we can of course introduce additional
> ioctl commands that always deal with 64 bit values, many other
> subsystems have been extended in similar ways.
[...]

Are there any ioctl interfaces to net_device_stats?  I didn't spot any.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

