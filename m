From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 1/2] net: Enable 64-bit net device statistics on
 32-bit architectures
Date: Tue, 08 Jun 2010 12:35:28 +0100
Message-ID: <1275996928.14011.83.camel@localhost>
References: <1275689093.2095.36.camel@achroite.uk.solarflarecom.com>
	 <20100607.211829.63035366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, arnd@arndb.de, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16878 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab0FHLfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 07:35:36 -0400
In-Reply-To: <20100607.211829.63035366.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-07 at 21:18 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 04 Jun 2010 23:04:53 +0100
> 
> > +#if BITS_PER_LONG == 64
> > +#define NET_DEVICE_STATS_DEFINE(name)	u64 name
> > +#elif defined(__LITTLE_ENDIAN)
> > +#define NET_DEVICE_STATS_DEFINE(name)	u32 name, pad_ ## name
> > +#else
> > +#define NET_DEVICE_STATS_DEFINE(name)	u32 pad_ ## name, name
> > +#endif
> > +
>  ...
> > +	NET_DEVICE_STATS_DEFINE(rx_packets);
> > +	NET_DEVICE_STATS_DEFINE(tx_packets);
> > +	NET_DEVICE_STATS_DEFINE(rx_bytes);
>  ...
> >  	static const char fmt[] = "%30s %12lu\n";
> > +	static const char fmt64[] = "%30s %12llu\n";
>  ...
> > +	seq_printf(seq, fmt64, "total frames received", stats->rx_packets);
> > +	seq_printf(seq, fmt64, "total bytes received", stats->rx_bytes);
> > +	seq_printf(seq, fmt64, "Broadcast/Multicast Rcvd", stats->multicast);
> 
> I guess you only built this on a 64-bit platform that defines u64 as a
> long long type.

There was some disussion of formatting u64 / unsigned long long in the
past and I thought the outcome of that was that u64 should always be
defined as unsigned long long.  (See commits fe33332 and 9018113.)

[...]
> And the whole tree needs to be inspected to make sure there isn't going
> to be fallout in areas your patch didn't take care of wrt. printf format
> strings and the like.
> 
> What was always "unsigned long" is now a variable type, therefore using
> a fixed printf format string is impossible unless you always cast these
> things when passed in as printf arguments.

Yes, that's true if there are drivers out there printing members of
net_device_stats.  I admit I haven't checked for that.  (Hmm, might be
time to try Coccinelle.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

