From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix bogus RTT on special retransmission
Date: Mon, 03 Mar 2014 15:37:01 -0500 (EST)
Message-ID: <20140303.153701.1237721833666659842.davem@davemloft.net>
References: <1393634546-18802-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, nanditad@google.com,
	netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298AbaCCUhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:37:03 -0500
In-Reply-To: <1393634546-18802-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 28 Feb 2014 16:42:26 -0800

> RTT may be bogus with tall loss probe (TLP) when a packet
> is retransmitted and latter (s)acked without TCPCB_SACKED_RETRANS flag.
> 
> For example, TLP calls __tcp_retransmit_skb() instead of
> tcp_retransmit_skb(). The skb timestamps are updated but the sacked
> flag is not marked with TCPCB_SACKED_RETRANS. As a result we'll
> get bogus RTT in tcp_clean_rtx_queue() or in tcp_sacktag_one() on
> spurious retransmission.
> 
> The fix is to apply the sticky flag TCP_EVER_RETRANS to enforce Karn's
> check on RTT sampling. However this will disable F-RTO if timeout occurs
> after TLP, by resetting undo_marker in tcp_enter_loss(). We relax this
> check to only if any pending retransmists are still in-flight.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thank you.
