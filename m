From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] ipv4: fix route deletion for IPs on many subnets
Date: Fri, 18 Mar 2011 21:57:51 -0700 (PDT)
Message-ID: <20110318.215751.108772214.davem@davemloft.net>
References: <alpine.LFD.2.00.1103190113420.1678@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48979
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752515Ab1CSE5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 00:57:13 -0400
In-Reply-To: <alpine.LFD.2.00.1103190113420.1678@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 19 Mar 2011 01:17:01 +0200 (EET)

> +	if (ifa->ifa_flags & IFA_F_SECONDARY) {
>  		prim = inet_ifa_byprefix(in_dev, any, ifa->ifa_mask);
>  		if (prim == NULL) {
>  			printk(KERN_WARNING "fib_del_ifaddr: bug: prim == NULL\n");
>  			return;
>  		}
> +		if (iprim && iprim != prim) {
> + printk(KERN_WARNING "fib_del_ifaddr: bug: iprim != prim\n");
> +			return;
> +		}
> +	} else if (!ipv4_is_zeronet(any) &&
> + (any != ifa->ifa_local || ifa->ifa_prefixlen < 32)) {
> +		fib_magic(RTM_DELROUTE,
> + dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
> +			  any, ifa->ifa_prefixlen, prim);
> +		subnet = 1;
>  	}
> 
>  	/* Deletion is more complicated than add.
> @@ -755,6 +769,49 @@ static void fib_del_ifaddr(struct in_ifa
 ...
> + /* Ignore ifa1 if it uses different primary IP (prefsrc) */
> +		if (ifa1->ifa_flags & IFA_F_SECONDARY) {
> +			/* Another address from our subnet? */
 ...
> + ifa1->ifa_mask != prim1->ifa_mask ||
> + !inet_ifa_match(ifa1->ifa_address, prim1))
> + prim1 = inet_ifa_byprefix(in_dev,
> + ifa1->ifa_address,
> + ifa1->ifa_mask);

Julian there exists all kinds of incorrect indentation in this patch,
could you please fix it up?

Thank you.
