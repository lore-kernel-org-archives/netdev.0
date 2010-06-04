From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] net: Enable 64-bit net device statistics on 32-bit
 architectures
Date: Fri, 4 Jun 2010 13:39:30 -0700
Message-ID: <20100604133930.34e2d53b@nehalam>
References: <1275576667.2106.11.camel@achroite.uk.solarflarecom.com>
	<1275586744.2106.22.camel@achroite.uk.solarflarecom.com>
	<20100603114738.41256434@nehalam>
	<1275592298.2106.36.camel@achroite.uk.solarflarecom.com>
	<20100604102852.08ce3cd1@nehalam>
	<1275675318.2095.30.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60566 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753897Ab0FDUjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 16:39:37 -0400
In-Reply-To: <1275675318.2095.30.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Jun 2010 19:15:18 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Fri, 2010-06-04 at 10:28 -0700, Stephen Hemminger wrote:
> > On Thu, 03 Jun 2010 20:11:38 +0100
> > Ben Hutchings <bhutchings@solarflare.com> wrote:
> > 
> > > static inline u64 rtnl_link_stats64_read(const u64 *field)
> > > {
> > > 	return ACCESS_ONCE(*field);
> > > }
> > > static inline u32 rtnl_link_stats64_read32(const u64 *field)
> > > {
> > > 	return ACCESS_ONCE(*field);
> > > }
> > 
> > Do we really care if compiler reorders access. I think not.
> > There was no order guarantee in the past.
> 
> Since these reads are potentially racing with writes, we want to ensure
> that they are atomic.  Without the volatile-qualification, the compiler
> can legitimately split or repeat the reads, though I don't see any
> particular reason why this is a likely optimisation.
> 
> Ben.
> 

But this part of the code is only being run on on 64 bit machines.
Updates of basic types for the CPU are atomic, lots of other code
already assumes this.
Take off your tin hat, this is excessive paranoia.

-- 
