From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: only static routes qualify for equal cost
 multipathing
Date: Thu, 11 Jul 2013 11:44:19 -0700 (PDT)
Message-ID: <20130711.114419.1045272869172136221.davem@davemloft.net>
References: <20130711170231.GA11078@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050Ab3GKSoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 14:44:20 -0400
In-Reply-To: <20130711170231.GA11078@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 11 Jul 2013 19:02:31 +0200

> +	for (rt = rt0; rt && !(rt->rt6i_flags & RTF_EXPIRES);
> +	     rt = (struct rt6_info *)rt->dst.from);
> +	return !(rt && (rt->rt6i_flags & RTF_EXPIRES));

Please make this logic clearer, something like:


	for (rt = rt0; rt; rt = (struct rt6_info *)rt->dst.from) {
		if (rt->rt6i_flags & RTF_EXPIRES)
			return false;
	}
	return true;

Thanks.
