From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 16:14:01 +0200
Message-ID: <1342620841.2626.2786.camel@edumazet-glaptop>
References: <1342613334.2626.2504.camel@edumazet-glaptop>
	 <1342619879.9551.14.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Tom Herbert <therbert@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:64379 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281Ab2GROOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 10:14:06 -0400
Received: by vbbff1 with SMTP id ff1so1115477vbb.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 07:14:05 -0700 (PDT)
In-Reply-To: <1342619879.9551.14.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 06:57 -0700, Joe Perches wrote:
> On Wed, 2012-07-18 at 14:08 +0200, Eric Dumazet wrote:
> > Introduce ipv6_addr_hash() helper doing a XOR on all bits
> > of an IPv6 address, with an optimized x86_64 version.
> []
> > diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> []
> > @@ -419,6 +419,19 @@ static inline bool ipv6_addr_any(const struct in6_addr *a)
> >  #endif
> >  }
> >  
> > +static inline u32 ipv6_addr_hash(const struct in6_addr *a)
> > +{
> > +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
> > +	const unsigned long *ul = (const unsigned long *)a;
> > +	unsigned long x = ul[0] ^ ul[1];
> > +
> > +	return x ^ (x >> 32);
> 
> Thanks Eric.
> 
> Perhaps this would be better with an explicit rather
> than implicit cast.

In fact, returning an "unsigned long" here might give more shuffling
capabilities on 64bit arches, thanks to hash_long()

but hash_long() on 64bit sounds a bit expensive for our needs...
