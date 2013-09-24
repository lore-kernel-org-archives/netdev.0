From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 09:32:30 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jesse.brandeburg@intel.com>
To: "Tom Herbert" <therbert@google.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51484 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750766Ab3IXIen convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 04:34:43 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30913-02 for <netdev@vger.kernel.org>;
 Tue, 24 Sep 2013 09:34:40 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static inline unsigned int
> +toeplitz_hash(const unsigned char *bytes,
> +	      struct toeplitz *toeplitz, int n)
> +{
> +	int i;
> +	unsigned int result = 0;
> +
> +	for (i = 0; i < n; i++)
> +		result ^= toeplitz->key_cache[i][bytes[i]];
> +
> +        return result;
> +};

That is a horrid hash function to be calculating in software.

The code looks very much like a simple 32bit CRC.
It isn't entirely clears exactly where the 'key' gets included,
but I suspect it is just xored with the data bytes.

Using in it hardware is probably fine - the hardware can do
it cheaply (in dedicated logic) as the frame arrives.
The CRC polynomial probably collapses to a few XOR operations
when done byte by byte (the hdlc crc16 collapses to 3 levels
of xor).

IIRC jhash() works on 32bit quantities - so has far fewer
maths operations and well as not having all the random data
accesses (cache misses and displacing other parts of the
working set from the cache).

I also thought the hash was arranged so that tx and rx packets
for a single connection hash to the same value?

	David
