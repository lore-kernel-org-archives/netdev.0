From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 19:30:02 -0700
Message-ID: <5715982A.7000801@cumulusnetworks.com>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com> <1461015356.10638.124.camel@edumazet-glaptop3.roam.corp.google.com> <20160418.205755.87909888849343438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	tgraf@suug.ch, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35085 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbcDSCaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 22:30:05 -0400
Received: by mail-pa0-f53.google.com with SMTP id fs9so1354582pac.2
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 19:30:04 -0700 (PDT)
In-Reply-To: <20160418.205755.87909888849343438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/16, 5:57 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 18 Apr 2016 14:35:56 -0700
>
>> On Mon, 2016-04-18 at 14:10 -0700, Roopa Prabhu wrote:
>>
>>> +	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64)) {
>>> +		struct rtnl_link_stats64 *sp;
>>> +
>>> +		attr = nla_reserve(skb, IFLA_STATS_LINK_64,
>>> +				   sizeof(struct rtnl_link_stats64));
>>> +		if (!attr)
>>> +			goto nla_put_failure;
>>> +
>>> +		sp = nla_data(attr);
>> Are you sure we have a guarantee that sp is aligned to u64 fields ?
>>
>> x86 does not care, but some arches would have a potential misalign
>> access here.
> I'll do some testing on sparc and deal with any fallout.
Thanks David. I will be happy to respin if you see problems.
