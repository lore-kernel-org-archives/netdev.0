From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Reject invalid ack_seq to Fast Open sockets
Date: Mon, 22 Oct 2012 23:59:37 +0200
Message-ID: <1350943177.8609.1383.camel@edumazet-glaptop>
References: <1350941196-31224-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com,
	ycheng@google.com
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53581 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787Ab2JVV7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 17:59:42 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so1701176wey.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 14:59:41 -0700 (PDT)
In-Reply-To: <1350941196-31224-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-22 at 14:26 -0700, H.K. Jerry Chu wrote:
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
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
