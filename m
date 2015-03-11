From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] tcp: fix tcp_cong_avoid_ai() credit
 accumulation bug with decreases in w
Date: Wed, 11 Mar 2015 16:52:08 -0400 (EDT)
Message-ID: <20150311.165208.101538124570318344.davem@davemloft.net>
References: <1426022224-28793-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbbCKUwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:52:10 -0400
In-Reply-To: <1426022224-28793-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 10 Mar 2015 17:17:03 -0400

> The recent change to tcp_cong_avoid_ai() to handle stretch ACKs
> introduced a bug where snd_cwnd_cnt could accumulate a very large
> value while w was large, and then if w was reduced snd_cwnd could be
> incremented by a large delta, leading to a large burst and high packet
> loss. This was tickled when CUBIC's bictcp_update() sets "ca->cnt =
> 100 * cwnd".
> 
> This bug crept in while preparing the upstream version of
> 814d488c6126.
> 
> Testing: This patch has been tested in datacenter netperf transfers
> and live youtube.com and google.com servers.
> 
> Fixes: 814d488c6126 ("tcp: fix the timid additive increase on stretch ACKs")
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
