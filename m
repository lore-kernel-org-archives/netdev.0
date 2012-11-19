From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] add DOVE extensions for VXLAN
Date: Mon, 19 Nov 2012 18:55:11 -0500 (EST)
Message-ID: <20121119.185511.672075914686268720.davem@davemloft.net>
References: <201211151347.qAFDkR8G023134@lab1.dls>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225Ab2KSXzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 18:55:14 -0500
In-Reply-To: <201211151347.qAFDkR8G023134@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <dlstevens@us.ibm.com>
Date: Thu, 15 Nov 2012 08:46:27 -0500

> @@ -111,6 +113,10 @@ struct vxlan_dev {
>  	__u8		  tos;		/* TOS override */
>  	__u8		  ttl;
>  	bool		  learn;
> +	bool		  proxy;	/* ARP reduction */
> +	bool		  rsc;		/* route short-circuit */
> +	bool		  l2miss;	/* L2 miss notifications */
> +	bool		  l3miss;	/* L3 miss notifications */
>  
>  	unsigned long	  age_interval;
>  	struct timer_list age_timer;

Perhaps we've accumulated enough boolean states that a "u32 flags" are
in order?

> +		for (i=0; i<ETH_ALEN; ++i)
> +			send_eth |= !!fdb->eth_addr[i];

Please use is_zero_ether_addr().

Otherwise these changes look fine to me, thanks.
