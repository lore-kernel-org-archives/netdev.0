From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp-tso: do not split TSO packets at
 retransmit time
Date: Sun, 24 Apr 2016 14:44:20 -0400 (EDT)
Message-ID: <20160424.144420.594314082130628842.davem@davemloft.net>
References: <1461261323-14355-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbcDXSoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 14:44:25 -0400
In-Reply-To: <1461261323-14355-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 21 Apr 2016 10:55:23 -0700

> Linux TCP stack painfully segments all TSO/GSO packets before retransmits.
> 
> This was fine back in the days when TSO/GSO were emerging, with their
> bugs, but we believe the dark age is over.
> 
> Keeping big packets in write queues, but also in stack traversal
> has a lot of benefits.
>  - Less memory overhead, because write queues have less skbs
>  - Less cpu overhead at ACK processing.
>  - Better SACK processing, as lot of studies mentioned how
>    awful linux was at this ;)
>  - Less cpu overhead to send the rtx packets
>    (IP stack traversal, netfilter traversal, drivers...)
>  - Better latencies in presence of losses.
>  - Smaller spikes in fq like packet schedulers, as retransmits
>    are not constrained by TCP Small Queues.
> 
> 1 % packet losses are common today, and at 100Gbit speeds, this
> translates to ~80,000 losses per second.
> Losses are often correlated, and we see many retransmit events
> leading to 1-MSS train of packets, at the time hosts are already
> under stress.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks Eric.
