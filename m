From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BK PATCH] Misc IPv6 Updates
Date: Wed, 10 Nov 2004 16:25:06 -0500 (EST)
Message-ID: <20041110.162506.124979704.yoshfuji@linux-ipv6.org>
References: <20041110.030026.29809367.yoshfuji@linux-ipv6.org>
	<OF8CA84FB0.6990A5CD-ON88256F48.0063D0E6-88256F48.0064C53C@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kumarkr@us.ibm.com
In-Reply-To: <OF8CA84FB0.6990A5CD-ON88256F48.0063D0E6-88256F48.0064C53C@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF8CA84FB0.6990A5CD-ON88256F48.0063D0E6-88256F48.0064C53C@us.ibm.com> (at Wed, 10 Nov 2004 10:20:40 -0800), Krishna Kumar <kumarkr@us.ibm.com> says:

> Is it faster to do :
> 
> +static inline int ipv6_addr_equal(const struct in6_addr *a1,
> +                                                  const struct in6_addr
> *a2)
> +{
> +            return (a1->s6_addr32[3] == a2->s6_addr32[3] &&
> +                        a1->s6_addr32[2] == a2->s6_addr32[2] &&
> +                        a1->s6_addr32[1] == a2->s6_addr32[1] &&
> +                        a1->s6_addr32[0] == a2->s6_addr32[0]);
> +}
> +
> 
> instead ?It should be faster for typical addresses, say 2000:a:b:c::1 and
> 2000:a:b:c::2. The device EUI-64 is
> normally going to be different for all devices while prefix can be same
> (atleast on a link/local site) completely
> or to some prefix len portion.

It depends on context and situation.
But, the difference is almost within the error range
compare to the this improvements to avoid using memcmp.

Anyway, the reason why the order is MSB->LSB is
 1. if you have multiple addresses with multiple prefixes + 
    same interface identifier, MSB->LSB is better.
 2. from the point of view of cache, MSB->LSB is better.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
