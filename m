From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: detect loss above high_seq in recovery
Date: Sun, 22 Jan 2012 14:24:16 -0500 (EST)
Message-ID: <20120122.142416.403336311074678485.davem@davemloft.net>
References: <1327020141-26883-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, ncardwell@google.com,
	nanditad@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab2AVTY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:24:28 -0500
In-Reply-To: <1327020141-26883-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 19 Jan 2012 16:42:21 -0800

> Correctly implement a loss detection heuristic: New sequences (above
> high_seq) sent during the fast recovery are deemed lost when higher
> sequences are SACKed.
> 
> Current code does not catch these losses, because tcp_mark_head_lost()
> does not check packets beyond high_seq. The fix is straight-forward by
> checking packets until the highest sacked packet. In addition, all the
> FLAG_DATA_LOST logic are in-effective and redundant and can be removed.
> 
> Update the loss heuristic comments. The algorithm above is documented
> as heuristic B, but it is redundant too because heuristic A already
> covers B.
> 
> Note that this change only marks some forward-retransmitted packets LOST.
> It does NOT forbid TCP performing further CWR on new losses. A potential
> follow-up patch under preparation is to perform another CWR on "new"
> losses such as
> 1) sequence above high_seq is lost (by resetting high_seq to snd_nxt)
> 2) retransmission is lost.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
