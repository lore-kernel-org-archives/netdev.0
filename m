From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT
 sample
Date: Tue, 10 Apr 2012 14:47:37 -0400 (EDT)
Message-ID: <20120410.144737.1047745906309843732.davem@davemloft.net>
References: <1334080760-968-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, ycheng@google.com,
	edumazet@google.com, therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758541Ab2DJSrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 14:47:41 -0400
In-Reply-To: <1334080760-968-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 10 Apr 2012 13:59:20 -0400

> Fix a code path in tcp_rcv_rtt_update() that was comparing scaled and
> unscaled RTT samples.
> 
> The intent in the code was to only use the 'm' measurement if it was a
> new minimum.  However, since 'm' had not yet been shifted left 3 bits
> but 'new_sample' had, this comparison would nearly always succeed,
> leading us to erroneously set our receive-side RTT estimate to the 'm'
> sample when that sample could be nearly 8x too high to use.
> 
> The overall effect is to often cause the receive-side RTT estimate to
> be significantly too large (up to 40% too large for brief periods in
> my tests).
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks.
