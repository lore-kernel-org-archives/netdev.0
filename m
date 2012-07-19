From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] ipv6: fix incorrect route 'expires' value passed to
 userspace
Date: Thu, 19 Jul 2012 10:49:06 -0700 (PDT)
Message-ID: <20120719.104906.38765587582698093.davem@davemloft.net>
References: <5003CC41.9080204@cn.fujitsu.com>
	<20120716.025649.1070277404591664104.davem@davemloft.net>
	<50076AD3.1060604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab2GSRtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:49:07 -0400
In-Reply-To: <50076AD3.1060604@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Thu, 19 Jul 2012 10:02:59 +0800

> 
> When userspace use RTM_GETROUTE to dump route table, with an already
> expired route entry, we always got an 'expires' value(2147157)
> calculated base on INT_MAX.
> 
> The reason of this problem is in the following satement:
> 	rt->dst.expires - jiffies < INT_MAX
> gcc promoted the type of both sides of '<' to unsigned long, thus
> a small negative value would be considered greater than INT_MAX.
> 
> This patch fix this by use the same trick as time_after macro to
> avoid the 'unsigned long' type promotion and deal with jiffies
> wrapping.
> 
> Also we should do some fix in rtnl_put_cacheinfo() which use
> jiffies_to_clock_t(which take an unsigned long as parameter) to
> convert jiffies to clock_t to handle the negative expires.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Your patch is corrupted by your email client and therefore will
not apply cleanly.

I think this isn't the first time your patch submissions have
had this problem, and if so then you should do the necessary
work to prevent problem with more certainty in the future as
such this makes a lot of extra work for other people.
