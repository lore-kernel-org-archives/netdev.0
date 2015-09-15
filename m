From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] rtnetlink: RTEXT_FILTER_SKIP_STATS support
 to avoid dumping inet/inet6 stats
Date: Tue, 15 Sep 2015 15:25:35 -0700 (PDT)
Message-ID: <20150915.152535.2037859496655270337.davem@davemloft.net>
References: <20150911204848.GC9687@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghavendra.kt@linux.vnet.ibm.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
	jose.marchesi@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbbIOWZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 18:25:36 -0400
In-Reply-To: <20150911204848.GC9687@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 11 Sep 2015 16:48:48 -0400

> 
> Many commonly used functions like getifaddrs() invoke RTM_GETLINK
> to dump the interface information, and do not need the
> the AF_INET6 statististics that are always returned by default
> from rtnl_fill_ifinfo().
> 
> Computing the statistics can be an expensive operation that impacts
> scaling, so it is desirable to avoid this if the information is
> not needed.
> 
> This patch adds a the RTEXT_FILTER_SKIP_STATS extended info flag that
> can be passed with netlink_request() to avoid statistics computation
> for the ifinfo path.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: David Miller comments: pass u32 ext_filter_mask down.
> v3: non-RFC version of v2.

Applied, with one minor change:

> +	if (!!(ext_filter_mask & RTEXT_FILTER_SKIP_STATS))

I got rid of the "!!" as it really isn't needed for an expression
like this.

Thanks!
