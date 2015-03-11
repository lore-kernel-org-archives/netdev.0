From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] tcp: restore 1.5x per RTT limit to CUBIC cwnd
 growth in congestion avoidance
Date: Wed, 11 Mar 2015 16:52:14 -0400 (EDT)
Message-ID: <20150311.165214.2047968573920569481.davem@davemloft.net>
References: <1426022224-28793-1-git-send-email-ncardwell@google.com>
	<1426022224-28793-2-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbbCKUwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:52:16 -0400
In-Reply-To: <1426022224-28793-2-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 10 Mar 2015 17:17:04 -0400

> Commit 814d488c6126 ("tcp: fix the timid additive increase on stretch
> ACKs") fixed a bug where tcp_cong_avoid_ai() would either credit a
> connection with an increase of snd_cwnd_cnt, or increase snd_cwnd, but
> not both, resulting in cwnd increasing by 1 packet on at most every
> alternate invocation of tcp_cong_avoid_ai().
> 
> Although the commit correctly implemented the CUBIC algorithm, which
> can increase cwnd by as much as 1 packet per 1 packet ACKed (2x per
> RTT), in practice that could be too aggressive: in tests on network
> paths with small buffers, YouTube server retransmission rates nearly
> doubled.
> 
> This commit restores CUBIC to a maximum cwnd growth rate of 1 packet
> per 2 packets ACKed (1.5x per RTT). In YouTube tests this restored
> retransmit rates to low levels.
> 
> Testing: This patch has been tested in datacenter netperf transfers
> and live youtube.com and google.com servers.
> 
> Fixes: 9cd981dcf174 ("tcp: fix stretch ACK bugs in CUBIC")
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
