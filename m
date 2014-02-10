From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: icmp6_send: fix Oops when pinging a not set up
 IPv6 peer on a sit tunnel
Date: Sun, 09 Feb 2014 18:13:09 -0800 (PST)
Message-ID: <20140209.181309.693568109095582800.davem@davemloft.net>
References: <1391768557-6337-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: fx.lebail@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213AbaBJCNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 21:13:10 -0500
In-Reply-To: <1391768557-6337-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Date: Fri,  7 Feb 2014 11:22:37 +0100

> The patch 446fab59333dea91e54688f033dd8d788d0486fb ("ipv6: enable anycast addresses
> as source addresses in ICMPv6 error messages") causes an Oops when pinging a not
> set up IPv6 peer on a sit tunnel.
> 
> The problem is that ipv6_anycast_destination() uses unconditionally skb_dst(skb),
> which is NULL in this case.
> 
> The solution is to use instead the ipv6_chk_acast_addr_src() function.
> 
> Here are the steps to reproduce it:
> modprobe sit
> ip link add sit1 type sit remote 10.16.0.121 local 10.16.0.249
> ip l s sit1 up
> ip -6 a a dev sit1 2001:1234::123 remote 2001:1234::121
> ping6 2001:1234::121
> 
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>

Applied, thank you.
