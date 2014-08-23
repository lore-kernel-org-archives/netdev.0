From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: improve undo on timeout
Date: Fri, 22 Aug 2014 21:28:18 -0700 (PDT)
Message-ID: <20140822.212818.342424006799582674.davem@davemloft.net>
References: <1408742122-23674-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbaHWE2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 00:28:19 -0400
In-Reply-To: <1408742122-23674-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 22 Aug 2014 14:15:22 -0700

> Upon timeout, undo (via both timestamps/Eifel and DSACKs) was
> disabled if any retransmits were still in flight.  The concern was
> perhaps that spurious retransmission sent in a previous recovery
> episode may trigger DSACKs to falsely undo the current recovery.
> 
> However, this inadvertently misses undo opportunities (using either
> TCP timestamps or DSACKs) when timeout occurs during a loss episode,
> i.e.  recurring timeouts or timeout during fast recovery. In these
> cases some retransmissions will be in flight but we should allow
> undo. Furthermore, we should only reset undo_marker and undo_retrans
> upon timeout if we are starting a new recovery episode. Finally,
> when we do reset our undo state, we now do so in a manner similar
> to tcp_enter_recovery(), so that we require a DSACK for each of
> the outstsanding retransmissions. This will achieve the original
> goal by requiring that we receive the same number of DSACKs as
> retransmissions.
> 
> This patch increases the undo events by 50% on Google servers.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Looks good, applied, thanks!
