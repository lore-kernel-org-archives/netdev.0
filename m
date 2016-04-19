From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 20:57:55 -0400 (EDT)
Message-ID: <20160418.205755.87909888849343438.davem@davemloft.net>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
	<1461015356.10638.124.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbcDSA6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 20:58:00 -0400
In-Reply-To: <1461015356.10638.124.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 18 Apr 2016 14:35:56 -0700

> On Mon, 2016-04-18 at 14:10 -0700, Roopa Prabhu wrote:
> 
>> +	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64)) {
>> +		struct rtnl_link_stats64 *sp;
>> +
>> +		attr = nla_reserve(skb, IFLA_STATS_LINK_64,
>> +				   sizeof(struct rtnl_link_stats64));
>> +		if (!attr)
>> +			goto nla_put_failure;
>> +
>> +		sp = nla_data(attr);
> 
> Are you sure we have a guarantee that sp is aligned to u64 fields ?
> 
> x86 does not care, but some arches would have a potential misalign
> access here.

I'll do some testing on sparc and deal with any fallout.
