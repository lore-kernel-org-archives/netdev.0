From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: make cwnd-limited checks
 measurement-based, and gentler
Date: Thu, 22 May 2014 11:49:42 -0400 (EDT)
Message-ID: <20140522.114942.1075238998098846288.davem@davemloft.net>
References: <1400769668-4908-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbaEVPv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 11:51:56 -0400
In-Reply-To: <1400769668-4908-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 22 May 2014 10:41:08 -0400

> Experience with the recent e114a710aa50 ("tcp: fix cwnd limited
> checking to improve congestion control") has shown that there are
> common cases where that commit can cause cwnd to be much larger than
> necessary. This leads to TSO autosizing cooking skbs that are too
> large, among other things.
> 
> The main problems seemed to be:
> 
> (1) That commit attempted to predict the future behavior of the
> connection by looking at the write queue (if TSO or TSQ limit
> sending). That prediction sometimes overestimated future outstanding
> packets.
> 
> (2) That commit always allowed cwnd to grow to twice the number of
> outstanding packets (even in congestion avoidance, where this is not
> needed).
> 
> This commit improves both of these, by:
> 
> (1) Switching to a measurement-based approach where we explicitly
> track the largest number of packets in flight during the past window
> ("max_packets_out"), and remember whether we were cwnd-limited at the
> moment we finished sending that flight.
> 
> (2) Only allowing cwnd to grow to twice the number of outstanding
> packets ("max_packets_out") in slow start. In congestion avoidance
> mode we now only allow cwnd to grow if it was fully utilized.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Neal.
