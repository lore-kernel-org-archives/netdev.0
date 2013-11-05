From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: properly handle stretch acks in slow
 start
Date: Mon, 04 Nov 2013 19:58:26 -0500 (EST)
Message-ID: <20131104.195826.303744401862156515.davem@davemloft.net>
References: <1383242851-26748-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
	vanj@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab3KEA62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 19:58:28 -0500
In-Reply-To: <1383242851-26748-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 31 Oct 2013 11:07:31 -0700

> Slow start now increases cwnd by 1 if an ACK acknowledges some packets,
> regardless the number of packets. Consequently slow start performance
> is highly dependent on the degree of the stretch ACKs caused by
> receiver or network ACK compression mechanisms (e.g., delayed-ACK,
> GRO, etc).  But slow start algorithm is to send twice the amount of
> packets of packets left so it should process a stretch ACK of degree
> N as if N ACKs of degree 1, then exits when cwnd exceeds ssthresh. A
> follow up patch will use the remainder of the N (if greater than 1)
> to adjust cwnd in the congestion avoidance phase.
> 
> In addition this patch retires the experimental limited slow start
> (LSS) feature. LSS has multiple drawbacks but questionable benefit. The
> fractional cwnd increase in LSS requires a loop in slow start even
> though it's rarely used. Configuring such an increase step via a global
> sysctl on different BDPS seems hard. Finally and most importantly the
> slow start overshoot concern is now better covered by the Hybrid slow
> start (hystart) enabled by default.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
