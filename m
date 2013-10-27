From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: do not rearm RTO when future data are sacked
Date: Sun, 27 Oct 2013 16:52:05 -0400 (EDT)
Message-ID: <20131027.165205.2096790124067371223.davem@davemloft.net>
References: <1382630367-21964-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, brakmo@google.com,
	netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813Ab3J0UwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 16:52:07 -0400
In-Reply-To: <1382630367-21964-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 24 Oct 2013 08:59:27 -0700

> Patch ed08495c3 "tcp: use RTT from SACK for RTO" always re-arms RTO upon
> obtaining a RTT sample from newly sacked data.
> 
> But technically RTO should only be re-armed when the data sent before
> the last (re)transmission of write queue head are (s)acked. Otherwise
> the RTO may continue to extend during loss recovery on data sent
> in the future.
> 
> Note that RTTs from ACK or timestamps do not have this problem, as the RTT
> source must be from data sent before.
> 
> The new RTO re-arm policy is
> 1) Always re-arm RTO if SND.UNA is advanced
> 2) Re-arm RTO if sack RTT is available, provided the sacked data was
>    sent before the last time write_queue_head was sent.
> 
> Signed-off-by: Larry Brakmo <brakmo@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Also applied and queued up for -stable, thanks!
