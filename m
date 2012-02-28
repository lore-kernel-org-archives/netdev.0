From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix false reordering signal in tcp_shifted_skb
Date: Tue, 28 Feb 2012 16:06:57 -0500 (EST)
Message-ID: <20120228.160657.419169586061006044.davem@davemloft.net>
References: <1330286779-10462-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, therbert@google.com,
	subramanian.vijay@gmail.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964902Ab2B1VHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 16:07:11 -0500
In-Reply-To: <1330286779-10462-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun, 26 Feb 2012 15:06:19 -0500

> When tcp_shifted_skb() shifts bytes from the skb that is currently
> pointed to by 'highest_sack' then the increment of
> TCP_SKB_CB(skb)->seq implicitly advances tcp_highest_sack_seq(). This
> implicit advancement, combined with the recent fix to pass the correct
> SACKed range into tcp_sacktag_one(), caused tcp_sacktag_one() to think
> that the newly SACKed range was before the tcp_highest_sack_seq(),
> leading to a call to tcp_update_reordering() with a degree of
> reordering matching the size of the newly SACKed range (typically just
> 1 packet, which is a NOP, but potentially larger).
> 
> This commit fixes this by simply calling tcp_sacktag_one() before the
> TCP_SKB_CB(skb)->seq advancement that can advance our notion of the
> highest SACKed sequence.
> 
> Correspondingly, we can simplify the code a little now that
> tcp_shifted_skb() should update the lost_cnt_hint in all cases where
> skb == tp->lost_skb_hint.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks Neal.
