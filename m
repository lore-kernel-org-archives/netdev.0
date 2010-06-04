From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: Enable 64-bit net device statistics on 32-bit
 architectures
Date: Fri, 04 Jun 2010 19:15:18 +0100
Message-ID: <1275675318.2095.30.camel@achroite.uk.solarflarecom.com>
References: <1275576667.2106.11.camel@achroite.uk.solarflarecom.com>
	 <1275586744.2106.22.camel@achroite.uk.solarflarecom.com>
	 <20100603114738.41256434@nehalam>
	 <1275592298.2106.36.camel@achroite.uk.solarflarecom.com>
	 <20100604102852.08ce3cd1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:16395 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724Ab0FDSPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 14:15:22 -0400
In-Reply-To: <20100604102852.08ce3cd1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-06-04 at 10:28 -0700, Stephen Hemminger wrote:
> On Thu, 03 Jun 2010 20:11:38 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > static inline u64 rtnl_link_stats64_read(const u64 *field)
> > {
> > 	return ACCESS_ONCE(*field);
> > }
> > static inline u32 rtnl_link_stats64_read32(const u64 *field)
> > {
> > 	return ACCESS_ONCE(*field);
> > }
> 
> Do we really care if compiler reorders access. I think not.
> There was no order guarantee in the past.

Since these reads are potentially racing with writes, we want to ensure
that they are atomic.  Without the volatile-qualification, the compiler
can legitimately split or repeat the reads, though I don't see any
particular reason why this is a likely optimisation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

