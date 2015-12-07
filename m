From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: start t5 timer only when peer rwnd is 0 and
 local state is SHUTDOWN_PENDING
Date: Sun, 06 Dec 2015 22:32:08 -0500 (EST)
Message-ID: <20151206.223208.1659505536548287003.davem@davemloft.net>
References: <dfbfa2ef370b0f8962933e7f9400f9588cdb2281.1449300936.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevic@redhat.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132AbbLGDcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 22:32:11 -0500
In-Reply-To: <dfbfa2ef370b0f8962933e7f9400f9588cdb2281.1449300936.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat,  5 Dec 2015 15:35:36 +0800

> when A sends a data to B, then A close() and enter into SHUTDOWN_PENDING
> state, if B neither claim his rwnd is 0 nor send SACK for this data, A
> will keep retransmitting this data until t5 timeout, Max.Retrans times
> can't work anymore, which is bad.
> 
> if B's rwnd is not 0, it should send abort after Max.Retrans times, only
> when B's rwnd == 0 and A's retransmitting beyonds Max.Retrans times, A
> will start t5 timer, which is also commit f8d960524328 ("sctp: Enforce
> retransmission limit during shutdown") means, but it lacks the condition
> peer rwnd == 0.
> 
> so fix it by adding a bit (zero_window_announced) in peer to record if
> the last rwnd is 0. If it was, zero_window_announced will be set. and use
> this bit to decide if start t5 timer when local.state is SHUTDOWN_PENDING.
> 
> Fixes: commit f8d960524328 ("sctp: Enforce retransmission limit during shutdown")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
