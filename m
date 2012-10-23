From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Reject invalid ack_seq to Fast Open sockets
Date: Tue, 23 Oct 2012 02:43:47 -0400 (EDT)
Message-ID: <20121023.024347.596104752673410505.davem@davemloft.net>
References: <1350941196-31224-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab2JWGns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:43:48 -0400
In-Reply-To: <1350941196-31224-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Mon, 22 Oct 2012 14:26:36 -0700

> From: Jerry Chu <hkchu@google.com>
> 
> A packet with an invalid ack_seq may cause a TCP Fast Open socket to switch
> to the unexpected TCP_CLOSING state, triggering a BUG_ON kernel panic.
> 
> When a FIN packet with an invalid ack_seq# arrives at a socket in
> the TCP_FIN_WAIT1 state, rather than discarding the packet, the current
> code will accept the FIN, causing state transition to TCP_CLOSING.
> 
> This may be a small deviation from RFC793, which seems to say that the
> packet should be dropped. Unfortunately I did not expect this case for
> Fast Open hence it will trigger a BUG_ON panic.
> 
> It turns out there is really nothing bad about a TFO socket going into
> TCP_CLOSING state so I could just remove the BUG_ON statements. But after
> some thought I think it's better to treat this case like TCP_SYN_RECV
> and return a RST to the confused peer who caused the unacceptable ack_seq
> to be generated in the first place.
> 
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>

Applied, thanks.

> -		BUG_ON(sk->sk_state != TCP_SYN_RECV &&
> +		WARN_ON_ONCE(sk->sk_state != TCP_SYN_RECV &&
>  		    sk->sk_state != TCP_FIN_WAIT1);

I fixed up the indentation of the second line of the test when I
applied this.
