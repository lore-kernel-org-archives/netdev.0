From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix false undo corner cases
Date: Mon, 07 Jul 2014 21:41:17 -0700 (PDT)
Message-ID: <20140707.214117.2003241916862387142.davem@davemloft.net>
References: <1404328036-2477-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbaGHElS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 00:41:18 -0400
In-Reply-To: <1404328036-2477-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed,  2 Jul 2014 12:07:16 -0700

> The undo code assumes that, upon entering loss recovery, TCP
> 1) always retransmit something
> 2) the retransmission never fails locally (e.g., qdisc drop)
> 
> so undo_marker is set in tcp_enter_recovery() and undo_retrans is
> incremented only when tcp_retransmit_skb() is successful.
> 
> When the assumption is broken because TCP's cwnd is too small to
> retransmit or the retransmit fails locally. The next (DUP)ACK
> would incorrectly revert the cwnd and the congestion state in
> tcp_try_undo_dsack() or tcp_may_undo(). Subsequent (DUP)ACKs
> may enter the recovery state. The sender repeatedly enter and
> (incorrectly) exit recovery states if the retransmits continue to
> fail locally while receiving (DUP)ACKs.
> 
> The fix is to initialize undo_retrans to -1 and start counting on
> the first retransmission. Always increment undo_retrans even if the
> retransmissions fail locally because they couldn't cause DSACKs to
> undo the cwnd reduction.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks.

Do you guys think this is -stable material?
