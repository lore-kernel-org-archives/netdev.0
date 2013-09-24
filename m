From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 05:24:34 -0700
Message-ID: <1380025474.3165.46.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f181.google.com ([209.85.213.181]:50527 "EHLO
	mail-ye0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3IXMYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 08:24:38 -0400
Received: by mail-ye0-f181.google.com with SMTP id r14so1658091yen.12
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 05:24:37 -0700 (PDT)
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
> 
> Using in it hardware is probably fine - the hardware can do
> it cheaply (in dedicated logic) as the frame arrives.
> The CRC polynomial probably collapses to a few XOR operations
> when done byte by byte (the hdlc crc16 collapses to 3 levels
> of xor).
> 
> IIRC jhash() works on 32bit quantities - so has far fewer
> maths operations and well as not having all the random data
> accesses (cache misses and displacing other parts of the
> working set from the cache).

Anyway, I really hope Toeplitz hash is not restricted to 0-255 range

Tom implementation is not Toeplitz, but a degenerated hash.
