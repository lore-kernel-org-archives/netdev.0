From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC] rtnetlink: add new RTM_GETSTATS to dump
 link stats
Date: Thu, 25 Feb 2016 21:01:10 -0800
Message-ID: <56CFDC16.1090809@cumulusnetworks.com>
References: <1456207293-36903-1-git-send-email-roopa@cumulusnetworks.com> <20160224.164003.357595978348193472.davem@davemloft.net> <56CE905E.4030601@cumulusnetworks.com> <20160225.112638.939367642956951530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34528 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbcBZFBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 00:01:12 -0500
Received: by mail-pf0-f180.google.com with SMTP id x65so45483682pfb.1
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 21:01:12 -0800 (PST)
In-Reply-To: <20160225.112638.939367642956951530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/25/16, 8:26 AM, David Miller wrote:
> From: roopa <roopa@cumulusnetworks.com>
> Date: Wed, 24 Feb 2016 21:25:50 -0800
>
>> I did go back and forth on the attribute vs mask.
>> cosmetic but, i guess i did not feel good about having to redefine every attribute again
>> for the bitmap filter ...and i anticipate the list of stat attributes to grow overtime (maybe there is a better way).
>> enum {
>>        IFLA_LINK_STATS64,
>>        IFLA_LINK_INET6_STATS,
>>        IFLA_LINK_MPLS_STATS,
>>        __IFLA_LINK_STATS_MAX,
>> };
>>
>> #define IFLA_LINK_STATS64_FILTER  0    
>> #define IFLA_LINK_INET6_STATS_FILTER (1 << 0)
>> #define IFLA_LINK_MPLS_STATS_FILTER (2 << 0)
> The filter for X is always (1 << X), so we could work with something like:
>
> #define IFLA_LINK_FILTER_BIT(ATTR)	(1 << (ATTR))
i like it
>
> Which seems to suggest that emitting no stats unless they are explicitly requested in
> the bitmask makes sense because:
>
> 1) You don't have to special case STATS64 in the filter mask
>
> 2) Application are forced to be aware of filtering and thus choose only
>    what they want to see
>
> How about this?
I am ok with it. It keeps the filtering mask handling consistent. Its a bit inconsistent with the other dump functions,
but this gives user full control of what combination of stats she wants. For something like stats, i think this makes sense.

Thanks again!
Roopa
