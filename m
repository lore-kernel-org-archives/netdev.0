From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: Fix SOF_TIMESTAMPING_TX_ACK when handling dup
 acks
Date: Thu, 21 Apr 2016 13:46:26 -0400 (EDT)
Message-ID: <20160421.134626.1196772506489683431.davem@davemloft.net>
References: <1461019193-3034571-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, edumazet@google.com,
	ncardwell@google.com, soheil.kdev@gmail.com, willemb@google.com,
	ycheng@google.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbcDURq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 13:46:29 -0400
In-Reply-To: <1461019193-3034571-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 18 Apr 2016 15:39:53 -0700

> Assuming SOF_TIMESTAMPING_TX_ACK is on. When dup acks are received,
> it could incorrectly think that a skb has already
> been acked and queue a SCM_TSTAMP_ACK cmsg to the
> sk->sk_error_queue.
> 
> In tcp_ack_tstamp(), it checks
> 'between(shinfo->tskey, prior_snd_una, tcp_sk(sk)->snd_una - 1)'.
> If prior_snd_una == tcp_sk(sk)->snd_una like the following packetdrill
> script, between() returns true but the tskey is actually not acked.
> e.g. try between(3, 2, 1).
> 
> The fix is to replace between() with one before() and one !before().
> By doing this, the -1 offset on the tcp_sk(sk)->snd_una can also be
> removed.
 ...
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied, thank you.
