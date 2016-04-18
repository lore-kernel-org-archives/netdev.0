From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 14:35:56 -0700
Message-ID: <1461015356.10638.124.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	tgraf@suug.ch, nicolas.dichtel@6wind.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32996 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbcDRVf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 17:35:58 -0400
Received: by mail-pa0-f48.google.com with SMTP id zm5so82769798pac.0
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 14:35:58 -0700 (PDT)
In-Reply-To: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 14:10 -0700, Roopa Prabhu wrote:

> +	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64)) {
> +		struct rtnl_link_stats64 *sp;
> +
> +		attr = nla_reserve(skb, IFLA_STATS_LINK_64,
> +				   sizeof(struct rtnl_link_stats64));
> +		if (!attr)
> +			goto nla_put_failure;
> +
> +		sp = nla_data(attr);

Are you sure we have a guarantee that sp is aligned to u64 fields ?

x86 does not care, but some arches would have a potential misalign
access here.


> +		dev_get_stats(dev, sp);
> +	}
