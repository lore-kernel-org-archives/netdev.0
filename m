From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Store idev entries (was: [PATCH][IPv6][IPsec] stop infinite loop)
Date: Wed, 4 May 2005 10:46:00 +1000
Message-ID: <20050504004600.GA19502@gondor.apana.org.au>
References: <4272EC95.20401@miyazawa.org> <20050430.120736.45974367.yoshfuji@linux-ipv6.org> <20050430031159.GA24326@gondor.apana.org.au> <20050430082339.GA20338@gondor.apana.org.au> <20050430114349.GA24573@gondor.apana.org.au> <20050503162628.7541807d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, kazunori@miyazawa.org, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050503162628.7541807d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 03, 2005 at 04:26:28PM -0700, David S. Miller wrote:
> 
> Applied, thanks Herbert.

Thanks Dave.

BTW, I was reviewing the rt6i_idev usage in IPv6 and it seems to me
that they need some protection with locking or RCU.  As it is they
are simply dereferenced in user/softirq context with no locking.

For example, the call chain udpv6_sendmsg -> ip6_dst_lookup ->
ipv6_get_saddr occurs in user context and simply dereferences
rt6i_idev.  The race condition is that another CPU could come
in and free rt6i_idev.  The reference count held by the dst
entry doesn't help since the other CPU will drop the reference
count for us through dst_ifdown.

Yoshifuji-san, does this look like a real problem to you?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
