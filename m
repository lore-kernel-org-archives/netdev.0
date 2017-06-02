From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: disallow cwnd undo when switching congestion
 control
Date: Fri, 02 Jun 2017 14:18:41 -0400 (EDT)
Message-ID: <20170602.141841.105030743435581987.davem@davemloft.net>
References: <20170531182127.161289-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751150AbdFBSSn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:18:43 -0400
In-Reply-To: <20170531182127.161289-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 31 May 2017 11:21:27 -0700

> When the sender switches its congestion control during loss
> recovery, if the recovery is spurious then it may incorrectly
> revert cwnd and ssthresh to the older values set by a previous
> congestion control. Consider a congestion control (like BBR)
> that does not use ssthresh and keeps it infinite: the connection
> may incorrectly revert cwnd to an infinite value when switching
> from BBR to another congestion control.
> 
> This patch fixes it by disallowing such cwnd undo operation
> upon switching congestion control.  Note that undo_marker
> is not reset s.t. the packets that were incorrectly marked
> lost would be corrected. We only avoid undoing the cwnd in
> tcp_undo_cwnd_reduction().
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks!
