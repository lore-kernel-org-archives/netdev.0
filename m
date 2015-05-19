From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] tcp: only undo on partial ACKs in CA_Loss
Date: Tue, 19 May 2015 16:37:21 -0400 (EDT)
Message-ID: <20150519.163721.637607343927285398.davem@davemloft.net>
References: <1431977505-15014-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbbESUhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:37:23 -0400
In-Reply-To: <1431977505-15014-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 18 May 2015 12:31:44 -0700

> Undo based on TCP timestamps should only happen on ACKs that advance
> SND_UNA, according to the Eifel algorithm in RFC 3522:
> 
> Section 3.2:
> 
>   (4) If the value of the Timestamp Echo Reply field of the
>       acceptable ACK's Timestamps option is smaller than the
>       value of RetransmitTS, then proceed to step (5),
> 
> Section Terminology:
>    We use the term 'acceptable ACK' as defined in [RFC793].  That is an
>    ACK that acknowledges previously unacknowledged data.
> 
> This is because upon receiving an out-of-order packet, the receiver
> returns the last timestamp that advances RCV_NXT, not the current
> timestamp of the packet in the DUPACK. Without checking the flag,
> the DUPACK will cause tcp_packet_delayed() to return true and
> tcp_try_undo_loss() will revert cwnd reduction.
> 
> Note that we check the condition in CA_Recovery already by only
> calling tcp_try_undo_partial() if FLAG_SND_UNA_ADVANCED is set or
> tcp_try_undo_recovery() if snd_una crosses high_seq.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
