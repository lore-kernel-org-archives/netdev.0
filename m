From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 17:38:59 +0100
Message-ID: <1380040739.2736.37.camel@bwh-desktop.uk.level5networks.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <jesse.brandeburg@intel.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40001 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369Ab3IXQjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:39:02 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 09:32 +0100, David Laight wrote:
> > +static inline unsigned int
> > +toeplitz_hash(const unsigned char *bytes,
> > +	      struct toeplitz *toeplitz, int n)
> > +{
> > +	int i;
> > +	unsigned int result = 0;
> > +
> > +	for (i = 0; i < n; i++)
> > +		result ^= toeplitz->key_cache[i][bytes[i]];
> > +
> > +        return result;
> > +};
> 
> That is a horrid hash function to be calculating in software.
> 
> The code looks very much like a simple 32bit CRC.
> It isn't entirely clears exactly where the 'key' gets included,
> but I suspect it is just xored with the data bytes.

Each input bit is multiplied by a 32-bit slice of the key and the
products are then bitwise-summed (i.e. xored).

[...]
> I also thought the hash was arranged so that tx and rx packets
> for a single connection hash to the same value?

Not in general.  I think I saw that one of the BSDs (DragonflyBSD?)
generates Toeplitz keys with this property and has an efficient software
implementation that works for those keys.  But that significantly
weakens the hash.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
