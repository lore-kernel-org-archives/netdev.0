From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_shift_skb_data() to not shift SACKed data
 below snd_una
Date: Tue, 06 Mar 2012 15:14:39 -0500 (EST)
Message-ID: <20120306.151439.182216414366813515.davem@davemloft.net>
References: <1331012104-20170-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030933Ab2CFUO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 15:14:57 -0500
In-Reply-To: <1331012104-20170-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue,  6 Mar 2012 00:35:04 -0500

> This commit fixes tcp_shift_skb_data() so that it does not shift
> SACKed data below snd_una.
> 
> This fixes an issue whose symptoms exactly match reports showing
> tp->sacked_out going negative since 3.3.0-rc4 (see "WARNING: at
> net/ipv4/tcp_input.c:3418" thread on netdev).
 ...
> After those two fixes, my testing has verified that shifting SACKed
> ranges below snd_una could cause tp->sacked_out to go negative with
> the following sequence of events:
> 
> (1) tcp_shift_skb_data() sees an skb whose end_seq is beyond snd_una,
>     then shifts a prefix of that skb that is below snd_una
 ...
> This fix changes tcp_shift_skb_data() to abort this sequence at step
> (1) in the scenario above by noticing that the bytes are below snd_una
> and not shifting them.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks.
