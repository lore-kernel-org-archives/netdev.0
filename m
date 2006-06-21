From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch] ipv6 source address selection in addrconf.c (2.6.17)
Date: Thu, 22 Jun 2006 00:12:35 +0900 (JST)
Message-ID: <20060622.001235.96410192.yoshfuji@linux-ipv6.org>
References: <44986AE6.6090102@poczta.fm>
	<44994CB3.6070302@poczta.fm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:6920 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751659AbWFUPLn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 11:11:43 -0400
To: stlman@poczta.fm
In-Reply-To: <44994CB3.6070302@poczta.fm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <44994CB3.6070302@poczta.fm> (at Wed, 21 Jun 2006 15:42:11 +0200), Lukasz Stelmach <stlman@poczta.fm> says:

> --- /usr/src/linux/net/ipv6/addrconf.c~	2006-06-21 11:41:22.000000000 +0200
> +++ /usr/src/linux/net/ipv6/addrconf.c	2006-06-21 15:33:26.000000000 +0200
> @@ -862,6 +862,8 @@
>    * 	2002::/16		2
>    * 	::/96			3
>    * 	::ffff:0:0/96		4
> +  *	fc00::/7		5
> +  * 	2001::/32		6
>    */
>  	if (type & IPV6_ADDR_LOOPBACK)
>  		return 0;
> @@ -871,6 +873,10 @@
>  		return 4;
>  	else if (addr->s6_addr16[0] == htons(0x2002))
>  		return 2;
> +	else if ((addr->s6_addr[0] & 0xfe) == 0xfc)
> +		return 5;
> +	else if (addr->s6_addr32[0] == htonl(0x20010000))
> +		return 6;
>  	return 1;
>  }
>  

Please put the comparison for 2001::/32 before 2002::/16.
Otherwise, I'm fine with it.

In addition, give us your sign-off, please.

Regards,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
