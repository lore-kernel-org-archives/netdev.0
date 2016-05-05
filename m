From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: Create FIB tables on link create
Date: Thu, 05 May 2016 00:24:48 -0400 (EDT)
Message-ID: <20160505.002448.1005276153595006235.davem@davemloft.net>
References: <1462421887-10712-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcEEE0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 00:26:06 -0400
In-Reply-To: <1462421887-10712-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  4 May 2016 21:18:07 -0700

> @@ -372,9 +372,13 @@ static int vrf_rt6_create(struct net_device *dev)
>  	if (!rt6)
>  		goto out;
>  
> -	rt6->dst.output	= vrf_output6;
> -	rt6->rt6i_table = fib6_get_table(net, vrf->tb_id);
>  	dst_hold(&rt6->dst);
> +
> +	rt6->rt6i_table = fib6_new_table(net, vrf->tb_id);
> +	if (!rt6->rt6i_table)
> +		goto out;
> +
> +	rt6->dst.output	= vrf_output6;
>  	vrf->rt6 = rt6;
>  	rc = 0;
>  out:

This leaks rt6.
