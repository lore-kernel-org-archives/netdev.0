From: Brian Haley <Brian.Haley@hp.com>
Subject: Re: [BK PATCH] Misc IPv6 Updates
Date: Wed, 10 Nov 2004 16:18:48 -0500
Message-ID: <419285B8.4070703@hp.com>
References: <OF8CA84FB0.6990A5CD-ON88256F48.0063D0E6-88256F48.0064C53C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?= <yoshfuji@linux-ipv6.org>,
        davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OF8CA84FB0.6990A5CD-ON88256F48.0063D0E6-88256F48.0064C53C@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Krishna Kumar wrote:
> (sorry if my mailer mangles the code)
> 
> In :
> 
> +static inline int ipv6_addr_equal(const struct in6_addr *a1,
> +   const struct in6_addr *a2)
> +{
> + return (a1->s6_addr32[0] == a2->s6_addr32[0] &&
> + a1->s6_addr32[1] == a2->s6_addr32[1] &&
> + a1->s6_addr32[2] == a2->s6_addr32[2] &&
> + a1->s6_addr32[3] == a2->s6_addr32[3]);
> +}
> +
> 
> Is it faster to do :
> 
> +static inline int ipv6_addr_equal(const struct in6_addr *a1,
> +   const struct in6_addr *a2)
> +{
> + return (a1->s6_addr32[3] == a2->s6_addr32[3] &&
> + a1->s6_addr32[2] == a2->s6_addr32[2] &&
> + a1->s6_addr32[1] == a2->s6_addr32[1] &&
> + a1->s6_addr32[0] == a2->s6_addr32[0]);
> +}
> +
> 
> instead ?It should be faster for typical addresses, say 2000:a:b:c::1 
> and 2000:a:b:c::2. The device EUI-64 is
> normally going to be different for all devices while prefix can be same 
> (atleast on a link/local site) completely
> or to some prefix len portion.

I think it might be fastest to do 3-0-2-1 as that will more quickly tell
a global from a link-local address.

I will eventually do a 64-bit comparison to see if putting an
#ifdef CONFIG_64BIT is worth it.

-Brian
