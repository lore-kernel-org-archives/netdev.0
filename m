From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Bug in ipv6_ifa_notify?
Date: Mon, 08 Nov 2004 08:30:03 -0500 (EST)
Message-ID: <20041108.083003.119488506.yoshfuji@linux-ipv6.org>
References: <20041108061529.GA1774@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, acme@conectiva.com.br, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20041108061529.GA1774@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041108061529.GA1774@gondor.apana.org.au> (at Mon, 8 Nov 2004 17:15:29 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> Hi:
> 
> I'm reviewing the changes between 2.6.8.1 and 2.6.9.  The following
> change caught my eye:
> 
> # ChangeSet
> #   2004/08/17 11:25:16+09:00 yoshfuji@linux-ipv6.org
> #   [IPV6] refer inet6 device via corresponding local route from address structure.
> 
> In particular, it changed the handling of RTM_NEWADDR in ipv6_ifa_notify.
> Previously if you received duplicate RTM_NEWADDR notifications
> ip6_rt_addr_add would allocate a new rt and then free it since
> ip6_ins_rt would fail.
> 
> With the new code, it will call ip6_ins_rt on the *same* rt
> again which will cause it to be dst_free'd.  I don't see any
> way for this to lead to dst underflows yet, but it'll certainly
> corrupt the routing table since dst_free modifies rt->u.next.
> 
> Now the question is is it possible to get dupliate RTM_NEWADDR
> notifications?

It used to (before http://linux.bkbits.net:8080/linux-2.5/cset@41216bc8qWlBbT2LRIeGJegBQQxczg).
But, it does not happen now; RTM_NEWADDR notification is called 
 1. when we has successfully finished DAD
or
 2. if the interface does not need DAD

We've tested simple (but including multiple multiple) up/down case.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
