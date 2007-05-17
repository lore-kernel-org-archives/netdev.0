From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [FIX][PATCH] ipv6 addrconf.c : wrong handling of non-ipv6
 hardware since 2.6.21
Date: Fri, 18 May 2007 02:49:40 +0900 (JST)
Message-ID: <20070518.024940.120305926.yoshfuji@linux-ipv6.org>
References: <464C886F.50703@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37751 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756111AbXEQRtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 13:49:21 -0400
In-Reply-To: <464C886F.50703@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <464C886F.50703@hartkopp.net> (at Thu, 17 May 2007 18:53:03 +0200), Oliver Hartkopp <socketcan@hartkopp.net> says:

> +static int ipv6_hwtype(struct net_device *dev)
> +{
> +    if ((dev->type == ARPHRD_ETHER) ||
> +        (dev->type == ARPHRD_LOOPBACK) ||
> +#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
> +        (dev->type == ARPHRD_SIT) ||
> +#endif
> +        (dev->type == ARPHRD_TUNNEL6) ||
> +        (dev->type == ARPHRD_FDDI) ||
> +        (dev->type == ARPHRD_IEEE802_TR) ||
> +        (dev->type == ARPHRD_ARCNET) ||
> +        (dev->type == ARPHRD_INFINIBAND))
> +        return 1;
> +
> +    return 0;
> +}
> +

Please remove #if, or please provide for other
dependencies as well (e.g., CONFIG_IPV6_TUNNEL etc.)

Otherwise, I would agree.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
