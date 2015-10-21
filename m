From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] RACK loss detection
Date: Wed, 21 Oct 2015 07:01:56 -0700 (PDT)
Message-ID: <20151021.070156.1837430079059548315.davem@davemloft.net>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbbJUNpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 09:45:38 -0400
In-Reply-To: <1445057867-32257-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 16 Oct 2015 21:57:40 -0700

> RACK (Recent ACK) loss recovery uses the notion of time instead of
> packet sequence (FACK) or counts (dupthresh).
> 
> It's inspired by the FACK heuristic in tcp_mark_lost_retrans(): when a
> limited transmit (new data packet) is sacked in recovery, then any
> retransmission sent before that newly sacked packet was sent must have
> been lost, since at least one round trip time has elapsed.
> 
> But that existing heuristic from tcp_mark_lost_retrans()
> has several limitations:
>   1) it can't detect tail drops since it depends on limited transmit
>   2) it's disabled upon reordering (assumes no reordering)
>   3) it's only enabled in fast recovery but not timeout recovery
> 
> RACK addresses these limitations with a core idea: an unacknowledged
> packet P1 is deemed lost if a packet P2 that was sent later is is
> s/acked, since at least one round trip has passed.
> 
> Since RACK cares about the time sequence instead of the data sequence
> of packets, it can detect tail drops when a later retransmission is
> s/acked, while FACK or dupthresh can't. For reordering RACK uses a
> dynamically adjusted reordering window ("reo_wnd") to reduce false
> positives on ever (small) degree of reordering, similar to the delayed
> Early Retransmit.
> 
> In the current patch set RACK is only a supplemental loss detection
> and does not trigger fast recovery. However we are developing RACK
> to replace or consolidate FACK/dupthresh, early retransmit, and
> thin-dupack. These heuristics all implicitly bear the time notion.
> For example, the delayed Early Retransmit is simply applying RACK
> to trigger the fast recovery with small inflight.
> 
> RACK requires measuring the minimum RTT. Tracking a global min is less
> robust due to traffic engineering pathing changes. Therefore it uses a
> windowed filter by Kathleen Nichols. The min RTT can also be useful
> for various other purposes like congestion control or stat monitoring.
> 
> This patch has been used on Google servers for well over 1 year. RACK
> has also been implemented in the QUIC protocol. We are submitting an
> IETF draft as well.

This looks really great, in fact in my eyes the entire series is
justified merely by patch #3 :-)

Series applied, thanks.
