From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Wed, 17 Feb 2016 13:05:04 -0500 (EST)
Message-ID: <20160217.130504.1799252766739262191.davem@davemloft.net>
References: <1455402207-9217-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423145AbcBQSFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 13:05:09 -0500
In-Reply-To: <1455402207-9217-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 13 Feb 2016 14:23:27 -0800

> @@ -3427,31 +3493,52 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  		write_lock_bh(&idev->lock);
>  	}
>  
> -	while (!list_empty(&idev->addr_list)) {
> -		ifa = list_first_entry(&idev->addr_list,
> -				       struct inet6_ifaddr, if_list);
> -		addrconf_del_dad_work(ifa);
> +	INIT_LIST_HEAD(&del_list);
> +	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
> +		bool keep_ifa = false;
>  
> -		list_del(&ifa->if_list);
> +		if (!how && keep_addr && ifa->user_managed)
> +			keep_ifa = true;

I think it would make sense to evaluate "!how && keep_addr" outside the
loop.  The only thing that changes is ifa->user_managed on each iteration.

But I also want some more documentation in what you are doing here.

I understand the address flushing on ifdown avoidance, but all of this
user_managed logic is not mentioned at all.  Why do you need it?  What
role does it play in achieving your goal?

Thanks.
