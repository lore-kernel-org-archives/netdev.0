From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] devinet: inetdev_init out label moved after RCU assignment
Date: Fri, 5 Jan 2007 11:52:54 -0800
Message-ID: <OFD7E91556.4F418D4A-ON8825725A.006CFD29-8825725A.006D366F@us.ibm.com>
References: <20070105111910.GA3650@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, greearb@candelatech.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:49618 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbXAETxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jan 2007 14:53:05 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l05JqxT5011729
	for <netdev@vger.kernel.org>; Fri, 5 Jan 2007 14:52:59 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l05JqxAi555060
	for <netdev@vger.kernel.org>; Fri, 5 Jan 2007 12:52:59 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l05Jqw4J020621
	for <netdev@vger.kernel.org>; Fri, 5 Jan 2007 12:52:59 -0700
In-Reply-To: <20070105111910.GA3650@ff.dom.local>
To: Jarek Poplawski <jarkao2@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yeah, sure.

                +-DLS

Acked-by: David L Stevens <dlstevens@us.ibm.com>

> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> ---
> 
> diff -Nurp linux-2.6.20-rc3-/net/ipv4/devinet.c 
linux-2.6.20-rc3/net/ipv4/devinet.c
> --- linux-2.6.20-rc3-/net/ipv4/devinet.c   2007-01-05 11:53:16.000000000 
+0100
> +++ linux-2.6.20-rc3/net/ipv4/devinet.c   2007-01-05 11:55:32.000000000 
+0100
> @@ -174,9 +174,10 @@ struct in_device *inetdev_init(struct ne
>     ip_mc_init_dev(in_dev);
>     if (dev->flags & IFF_UP)
>        ip_mc_up(in_dev);
> -out:
> +
>     /* we can receive as soon as ip_ptr is set -- do this last */
>     rcu_assign_pointer(dev->ip_ptr, in_dev);
> +out:
>     return in_dev;
>  out_kfree:
>     kfree(in_dev);
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

