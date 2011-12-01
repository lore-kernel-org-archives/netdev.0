From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/2] netem: rate extension
Date: Wed, 30 Nov 2011 23:19:03 -0500 (EST)
Message-ID: <20111130.231903.333204297403823043.davem@davemloft.net>
References: <1322691627-20551-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753989Ab1LAETK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:19:10 -0500
In-Reply-To: <1322691627-20551-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed, 30 Nov 2011 23:20:26 +0100

> Currently netem is not in the ability to emulate channel bandwidth. Only static
> delay (and optional random jitter) can be configured.
> 
> To emulate the channel rate the token bucket filter (sch_tbf) can be used.  But
> TBF has some major emulation flaws. The buffer (token bucket depth/rate) cannot
> be 0. Also the idea behind TBF is that the credit (token in buckets) fills if
> no packet is transmitted. So that there is always a "positive" credit for new
> packets. In real life this behavior contradicts the law of nature where
> nothing can travel faster as speed of light. E.g.: on an emulated 1000 byte/s
> link a small IPv4/TCP SYN packet with ~50 byte require ~0.05 seconds - not 0
> seconds.
> 
> Netem is an excellent place to implement a rate limiting feature: static
> delay is already implemented, tfifo already has time information and the
> user can skip TBF configuration completely.
> 
> This patch implement rate feature which can be configured via tc. e.g:
> 
> 	tc qdisc add dev eth0 root netem rate 10kbit
> 
> To emulate a link of 5000byte/s and add an additional static delay of 10ms:
> 
> 	tc qdisc add dev eth0 root netem delay 10ms rate 5KBps
> 
> Note: similar to TBF the rate extension is bounded to the kernel timing
> system. Depending on the architecture timer granularity, higher rates (e.g.
> 10mbit/s and higher) tend to transmission bursts. Also note: further queues
> living in network adaptors; see ethtool(8).
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
