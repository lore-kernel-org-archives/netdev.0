From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: Bug in Linux 2.5.74 IPv6 routing
Date: Thu, 10 Jul 2003 03:31:17 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710.033117.93244305.yoshfuji@linux-ipv6.org>
References: <20030709195237.A8550@horus.imag.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean-Luc.Richier@imag.fr
In-Reply-To: <20030709195237.A8550@horus.imag.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

CC: netdev

In article <20030709195237.A8550@horus.imag.fr> (at Wed, 9 Jul 2003 19:52:37 +0200), Jean-Luc Richier <Jean-Luc.Richier@imag.fr> says:

> There is a bug in IPv6 route calculation since kernel 2.5.71. It affects
> all routes with prefix length != 0 (mod 8)
> The bug is as follows:
> do:	ip -6 route add 2000::/3 via 2001:688:121:10::1
> 	ip -6 route
> It shows a route for ::/3, not for 2000::/3

good catch.

> PATCH 2: avoid overwriting the set value
> --- linux-2.5.74/include/net/ipv6.h.DIST	2003-07-02 22:53:44.000000000 +0200
> +++ linux-2.5.74/include/net/ipv6.h	2003-07-09 18:51:25.000000000 +0200
> @@ -276,8 +276,10 @@
>  	    b = plen & 0x7;
>  
>  	memcpy(pfx->s6_addr, addr, o);
> -	if (b != 0)
> +	if (b != 0) {
>  		pfx->s6_addr[o] = addr->s6_addr[o] & (0xff00 >> b);
> +		o++;
> +	}
>  	if (o < 16)
>  		memset(pfx->s6_addr + o, 0, 16 - o);
>  }
> 

Ok, let's use this one.

--yoshfuji
