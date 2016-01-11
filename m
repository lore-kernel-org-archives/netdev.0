From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp_yeah: don't set ssthresh below 2
Date: Mon, 11 Jan 2016 17:25:48 -0500 (EST)
Message-ID: <20160111.172548.746102330510579400.davem@davemloft.net>
References: <1452537763-28163-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933512AbcAKWZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 17:25:52 -0500
In-Reply-To: <1452537763-28163-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 11 Jan 2016 13:42:43 -0500

> For tcp_yeah, use an ssthresh floor of 2, the same floor used by Reno
> and CUBIC, per RFC 5681 (equation 4).
> 
> tcp_yeah_ssthresh() was sometimes returning a 0 or negative ssthresh
> value if the intended reduction is as big or bigger than the current
> cwnd. Congestion control modules should never return a zero or
> negative ssthresh. A zero ssthresh generally results in a zero cwnd,
> causing the connection to stall. A negative ssthresh value will be
> interpreted as a u32 and will set a target cwnd for PRR near 4
> billion.
> 
> Oleksandr Natalenko reported that a system using tcp_yeah with ECN
> could see a warning about a prior_cwnd of 0 in
> tcp_cwnd_reduction(). Testing verified that this was due to
> tcp_yeah_ssthresh() misbehaving in this way.
> 
> Reported-by: Oleksandr Natalenko <oleksandr@natalenko.name>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks!
