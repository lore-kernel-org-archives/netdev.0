From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: increase throughput when reordering is
 high
Date: Thu, 22 Aug 2013 14:40:17 -0700 (PDT)
Message-ID: <20130822.144017.1466549111461976435.davem@davemloft.net>
References: <1377131363-31341-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648Ab3HVVkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 17:40:18 -0400
In-Reply-To: <1377131363-31341-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 21 Aug 2013 17:29:23 -0700

> The stack currently detects reordering and avoid spurious
> retransmission very well. However the throughput is sub-optimal under
> high reordering because cwnd is increased only if the data is deliverd
> in order. I.e., FLAG_DATA_ACKED check in tcp_ack().  The more packet
> are reordered the worse the throughput is.
> 
> Therefore when reordering is proven high, cwnd should advance whenever
> the data is delivered regardless of its ordering. If reordering is low,
> conservatively advance cwnd only on ordered deliveries in Open state,
> and retain cwnd in Disordered state (RFC5681).
> 
> Using netperf on a qdisc setup of 20Mbps BW and random RTT from 45ms
> to 55ms (for reordering effect). This change increases TCP throughput
> by 20 - 25% to near bottleneck BW.
> 
> A special case is the stretched ACK with new SACK and/or ECE mark.
> For example, a receiver may receive an out of order or ECN packet with
> unacked data buffered because of LRO or delayed ACK. The principle on
> such an ACK is to advance cwnd on the cummulative acked part first,
> then reduce cwnd in tcp_fastretrans_alert().
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, your team is doing great work on the TCP stack!
