From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: remove cwnd moderation after recovery
Date: Sat, 02 Apr 2016 20:14:21 -0400 (EDT)
Message-ID: <20160402.201421.1535372805780247767.davem@davemloft.net>
References: <1459374860-32643-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mattmathis@google.com,
	ncardwell@google.com, soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbcDCAOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 20:14:25 -0400
In-Reply-To: <1459374860-32643-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 30 Mar 2016 14:54:20 -0700

> For non-SACK connections, cwnd is lowered to inflight plus 3 packets
> when the recovery ends. This is an optional feature in the NewReno
> RFC 2582 to reduce the potential burst when cwnd is "re-opened"
> after recovery and inflight is low.
> 
> This feature is questionably effective because of PRR: when
> the recovery ends (i.e., snd_una == high_seq) NewReno holds the
> CA_Recovery state for another round trip to prevent false fast
> retransmits. But if the inflight is low, PRR will overwrite the
> moderated cwnd in tcp_cwnd_reduction() later regardlessly. So if a
> receiver responds bogus ACKs (i.e., acking future data) to speed up
> transfer after recovery, it can only induce a burst up to a window
> worth of data packets by acking up to SND.NXT. A restart from (short)
> idle or receiving streched ACKs can both cause such bursts as well.
> 
> On the other hand, if the recovery ends because the sender
> detects the losses were spurious (e.g., reordering). This feature
> unconditionally lowers a reverted cwnd even though nothing
> was lost.
> 
> By principle loss recovery module should not update cwnd. Further
> pacing is much more effective to reduce burst. Hence this patch
> removes the cwnd moderation feature.
> 
> v2 changes: revised commit message on bogus ACKs and burst, and
>             missing signature
> 
> Signed-off-by: Matt Mathis <mattmathis@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks.
