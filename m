From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
 else")
Date: Tue, 31 Aug 2004 13:54:21 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408311326540.4022-100000@l>
References: <20040831101203.GA1951@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, <laforge@netfilter.org>,
        <netfilter-devel@lists.netfilter.org>, <rusty@rustcorp.com.au>,
        <netdev@oss.sgi.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040831101203.GA1951@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 31 Aug 2004, Herbert Xu wrote:

> I knew it can't be that easy :)
>
> So let's go back to the previous idea of using inet_select_addr?
> Can you find any problems with this? In fact, it seems that the
> 2.2 compatibility code does exactly this.

	Yes, 2.2 worked somehow, until some users wanted more
control from the routing. Now ip_fw_compat_masq.c has such call,
it can be fast in some setups with small number of IPs but may
be now there some setups using nfmark for selecting maddr from
ISP-specific routing tables. I'm not sure we can avoid the routing
and the cache pollution, we have to live with the old behavoir, not
the current one.

	I have some related work, you can check it for more ideas:

http://www.ssi.bg/~ja/#routes
see dgd-usage.txt

	In short, I use the mpath route as a nexthop selector (on
first packet), the next packets do not hit the mpath route, they feed the 
routing with the maddr already bound to the NAT connection. This survives
cache expiration. May be using connmark is a better idea:
assign nfmark to connection and route it always via same GW. But
may be the oif key remains, I'm not sure.

Regards

--
Julian Anastasov <ja@ssi.bg>
