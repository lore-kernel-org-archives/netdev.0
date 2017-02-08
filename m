From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] sierra_net: Add support for IPv6 and Dual-Stack
 Link Sense Indications
Date: Wed, 08 Feb 2017 10:23:40 -0500 (EST)
Message-ID: <20170208.102340.236303502527636848.davem@davemloft.net>
References: <20170208014633.15438-1-stefan.bruens@rwth-aachen.de>
        <916d0ee7460a4fcfaa1a951cf39e8607@rwthex-w2-b.rwth-ad.de>
        <87inolropl.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: stefan.bruens@rwth-aachen.de, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bjorn@mork.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87inolropl.fsf@miraculix.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjørn Mork <bjorn@mork.no>
Date: Wed, 08 Feb 2017 10:55:50 +0100

> Stefan Brüns <stefan.bruens@rwth-aachen.de> writes:
> 
>> If a context is configured as dualstack ("IPv4v6"), the modem indicates
>> the context activation with a slightly different indication message.
>> The dual-stack indication omits the link_type (IPv4/v6) and adds
>> additional address fields.
> 
> Great!
> 
>> IPv6 LSIs are identical to IPv4 LSIs, but have a different link type.
>> +struct lsi_umts_dual {
>> +	struct lsi_umts lsi;
>> +	u8 pdp_addr4_len; /* NW-supplied PDP IPv4 address len */
>> +	u8 pdp_addr4[4];  /* NW-supplied PDP IPv4 address (bigendian)) */
>> +	u8 pdp_addr6_len; /* NW-supplied PDP IPv6 address len */
>> +	u8 pdp_addr6[16]; /* NW-supplied PDP IPv6 address (bigendian)) */
> 
> 
> Maybe use "struct in_addr" and "struct in6_addr" for all the address
> fields, making them a bit more accessible and avoiding having to define
> endianness explicitly?

Can't do that, it will add padding to the structure and not match
what is really in the header.

The problem is that we get a "u8" length first which starts the
address on an odd byte.

And we don't want to use "__packed" to fix this either.
