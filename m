From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC] rtnetlink: add new RTM_GETSTATS to dump
 link stats
Date: Thu, 25 Feb 2016 11:26:38 -0500 (EST)
Message-ID: <20160225.112638.939367642956951530.davem@davemloft.net>
References: <1456207293-36903-1-git-send-email-roopa@cumulusnetworks.com>
	<20160224.164003.357595978348193472.davem@davemloft.net>
	<56CE905E.4030601@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373AbcBYQ0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:26:42 -0500
In-Reply-To: <56CE905E.4030601@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Wed, 24 Feb 2016 21:25:50 -0800

> I did go back and forth on the attribute vs mask.
> cosmetic but, i guess i did not feel good about having to redefine every attribute again
> for the bitmap filter ...and i anticipate the list of stat attributes to grow overtime (maybe there is a better way).
> enum {
>        IFLA_LINK_STATS64,
>        IFLA_LINK_INET6_STATS,
>        IFLA_LINK_MPLS_STATS,
>        __IFLA_LINK_STATS_MAX,
> };
> 
> #define IFLA_LINK_STATS64_FILTER  0    
> #define IFLA_LINK_INET6_STATS_FILTER (1 << 0)
> #define IFLA_LINK_MPLS_STATS_FILTER (2 << 0)

The filter for X is always (1 << X), so we could work with something like:

#define IFLA_LINK_FILTER_BIT(ATTR)	(1 << (ATTR))

Which seems to suggest that emitting no stats unless they are explicitly requested in
the bitmask makes sense because:

1) You don't have to special case STATS64 in the filter mask

2) Application are forced to be aware of filtering and thus choose only
   what they want to see

How about this?
