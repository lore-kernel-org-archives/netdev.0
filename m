From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: zero retrans_stamp if all retrans were acked
Date: Tue, 4 Nov 2014 13:51:31 -0500
Message-ID: <CADVnQynOfg6PDe0XYW+0uM+Kbqhv7RRTrEAJCrCEEY54Q6U8Eg@mail.gmail.com>
References: <66a8a101a2bfe645432ec393d22b9da44b9739cf.1415110605.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:49794 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbaKDSvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 13:51:32 -0500
Received: by mail-oi0-f47.google.com with SMTP id a3so10254933oib.34
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 10:51:32 -0800 (PST)
In-Reply-To: <66a8a101a2bfe645432ec393d22b9da44b9739cf.1415110605.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 9:18 AM, Marcelo Ricardo Leitner
<mleitner@redhat.com> wrote:
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index a12b455928e52211efdc6b471ef54de6218f5df0..65686efeaaf3c36706390d3bfd260fd1fb942b7f 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2410,6 +2410,8 @@ static bool tcp_try_undo_recovery(struct sock *sk)
>                  * is ACKed. For Reno it is MUST to prevent false
>                  * fast retransmits (RFC2582). SACK TCP is safe. */
>                 tcp_moderate_cwnd(tp);
> +               if (!tcp_any_retrans_done(sk))
> +                       tp->retrans_stamp = 0;

I ran into a compilation error with this, since tcp_any_retrans_done()
is defined below this spot in the file.

I'd recommend moving the tcp_any_retrans_done() code and its preceding
block comment to just above the spot in tcp_input.c that says "/* Undo
procedures. */". That way it compiles.

In the meantime, Yuchung put together a nice packetdrill test case for
this, so I'll run it on that version of the patch.

neal
