From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ila: ipv6/ila: fix nlsize calculation for
 lwtunnel
Date: Sun, 01 May 2016 19:39:26 -0400 (EDT)
Message-ID: <20160501.193926.994161705403597197.davem@davemloft.net>
References: <1461888749-4105343-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
	nicolas.dichtel@6wind.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbcEAXj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 19:39:28 -0400
In-Reply-To: <1461888749-4105343-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 28 Apr 2016 17:12:29 -0700

> @@ -144,8 +144,12 @@ nla_put_failure:
>  
>  static int ila_encap_nlsize(struct lwtunnel_state *lwtstate)
>  {
> -	/* No encapsulation overhead */
> -	return 0;
> +	return
> +		/* ILA_ATTR_LOCATOR */
> +		nla_total_size(sizeof(u64)) +

As Nicolas stated, you need to use the 64-bit sizing helper here.
