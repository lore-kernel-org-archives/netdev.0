From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3 v4] net: ipv4 sysctl option to ignore
 routes when nexthop link is down
Date: Thu, 18 Jun 2015 03:27:58 -0700 (PDT)
Message-ID: <20150618.032758.842689503494499354.davem@davemloft.net>
References: <1434386001-1157-1-git-send-email-gospo@cumulusnetworks.com>
	<1434386001-1157-3-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com,
	sfeldma@gmail.com, alexander.duyck@gmail.com,
	hannes@stressinduktion.org, stephen@networkplumber.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817AbbFRKQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 06:16:19 -0400
In-Reply-To: <1434386001-1157-3-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Mon, 15 Jun 2015 12:33:20 -0400

> @@ -1035,12 +1036,18 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>  	    nla_put_in_addr(skb, RTA_PREFSRC, fi->fib_prefsrc))
>  		goto nla_put_failure;
>  	if (fi->fib_nhs == 1) {
> +		struct in_device *in_dev;
>  		if (fi->fib_nh->nh_gw &&
>  		    nla_put_in_addr(skb, RTA_GATEWAY, fi->fib_nh->nh_gw))
>  			goto nla_put_failure;

Please put an empty line between local variable declarations and code.

> @@ -1057,11 +1064,17 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>  			goto nla_put_failure;
>  
>  		for_nexthops(fi) {
> +			struct in_device *in_dev;
>  			rtnh = nla_reserve_nohdr(skb, sizeof(*rtnh));
>  			if (!rtnh)
>  				goto nla_put_failure;

Likewise.
