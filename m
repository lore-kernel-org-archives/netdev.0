From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4430] New: Virtual interfaces cannot have their own mtu
Date: Fri, 01 Apr 2005 21:46:29 +1000
Message-ID: <E1DHKbd-0000pi-00@gondolin.me.apana.org.au>
References: <20050401021121.76da449b.akpm@osdl.org>
Cc: netdev@oss.sgi.com, lukeross@sys3175.co.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20050401021121.76da449b.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
> the eth0:1 to 9000. However it is not possible to set the mtu for eth0:1 to 9000
> without setting the mtu of eth0 to 9000 as well.

The solution is to set the mtu using ip route in addition to setting
it on eth0, e.g.,

ip ro add x.0.0.0/8 via gw dev eth0 mtu 1500 src a.b.c.d
ip ro add y.0.0.0/8 via gw2 dev eth0 mtu 9000 src e.f.g.h

You still have to set the mtu on eth0 to 9000 since that determines
the maximum receive size as well (MRU).
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
