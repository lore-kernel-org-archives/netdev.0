From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6.17] net/ipv6/udp.c: remove duplicate udp_get_port
 code
Date: Wed, 16 Aug 2006 17:51:44 +0900 (JST)
Message-ID: <20060816.175144.75075807.yoshfuji@linux-ipv6.org>
References: <200608160846.48174@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:11792 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751020AbWHPIuC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 04:50:02 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200608160846.48174@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <200608160846.48174@strip-the-willow> (at Wed, 16 Aug 2006 08:46:48 +0100), gerrit@erg.abdn.ac.uk says:

> UDPv4 and UDPv6 use an almost identical version of the get_port function,
> which is unnecessary since the (long) code differs in only one if-statement.
:

:
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +				else if(sk->sk_family == PF_INET6     &&
> +					ipv6_rcv_saddr_equal(sk, sk2)     )
> +					goto fail;
> +			}
> +#endif

This is not good because you cannot link ipv6_rcv_saddr_equal()
if you are compiling IPv6 as module.

How about retaining udp_v{4,6}_get_port() and call
common udp_get_port() from both functions?

--yoshfuji
