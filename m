From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: ip_check_defrag must not modify skb before
 unsharing
Date: Mon, 10 Dec 2012 13:41:46 -0500 (EST)
Message-ID: <20121210.134146.1583909966821253233.davem@davemloft.net>
References: <1354919017.9124.33.camel@jlt4.sipsolutions.net>
	<1355131788.9857.1.camel@jlt4.sipsolutions.net>
	<1355132466.9857.6.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric@regit.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com,
	eric.dumazet@gmail.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab2LJSlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 13:41:49 -0500
In-Reply-To: <1355132466.9857.6.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 10 Dec 2012 10:41:06 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> ip_check_defrag() might be called from af_packet within the
> RX path where shared SKBs are used, so it must not modify
> the input SKB before it has unshared it for defragmentation.
> Use skb_copy_bits() to get the IP header and only pull in
> everything later.
> 
> The same is true for the other caller in macvlan as it is
> called from dev->rx_handler which can also get a shared SKB.
> 
> Reported-by: Eric Leblond <eric@regit.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
> For some versions of the kernel, this code goes into af_packet.c

So the bug is that ip_check_defrag() has a precondition which is met
properly by all callers except AF_PACKET.

If this is the case, remind me why are we changing ip_check_defrag()
rather than the violator of the precondition?
