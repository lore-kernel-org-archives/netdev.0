From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: Reject invalid ack_seq to Fast Open sockets
Date: Mon, 22 Oct 2012 20:56:18 -0400
Message-ID: <CADVnQyne=GcdafOP8ZrCu+=6aRiqTToyGbWB6PCsNMCdXku1kA@mail.gmail.com>
References: <1350941196-31224-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:34745 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab2JWA4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 20:56:18 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so2561743iag.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 17:56:18 -0700 (PDT)
In-Reply-To: <1350941196-31224-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 5:26 PM, H.K. Jerry Chu <hkchu@google.com> wrote:
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

Acked-by: Neal Cardwell <ncardwell@google.com>
