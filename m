From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Mon, 9 Feb 2009 22:10:32 +0800
Message-ID: <b6a2187b0902090610v56cc0789m1bbb144994078474@mail.gmail.com>
References: <20090206054541.GA4954@gondor.apana.org.au>
	 <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com>
	 <20090209055848.GA3889@gondor.apana.org.au>
	 <20090208.220357.261414983.davem@davemloft.net>
	 <20090209061151.GA3982@gondor.apana.org.au>
	 <Pine.LNX.4.64.0902090853360.20576@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	torvalds@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:65346 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbZBIOKe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 09:10:34 -0500
In-Reply-To: <Pine.LNX.4.64.0902090853360.20576@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 9, 2009 at 3:13 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki=
=2Efi> wrote:
>  net/ipv4/tcp_output.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 557fe16..c808d73 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -667,7 +667,8 @@ static int tcp_transmit_skb(struct sock *sk, stru=
ct sk_buff *skb, int clone_it,
>                if (between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFF=
=46)) {
>                        th->urg_ptr =3D htons(tp->snd_up - tcb->seq);
>                        th->urg =3D 1;
> -               } else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
> +               } else if (after(tcb->seq + 0xFFFF, tp->snd_nxt) &&
> +                          before(tcb->seq, tcp->snd_up)) {
>                        th->urg_ptr =3D 0xFFFF;
>                        th->urg =3D 1;
>                }
> --
> 1.5.6.5
>

Ilpo,

Got this error ...

  CC      net/ipv4/tcp_output.o
net/ipv4/tcp_output.c: In function 'tcp_transmit_skb':
net/ipv4/tcp_output.c:671: error: 'tcp' undeclared (first use in this f=
unction)
net/ipv4/tcp_output.c:671: error: (Each undeclared identifier is
reported only once
net/ipv4/tcp_output.c:671: error: for each function it appears in.)

> +                          before(tcb->seq, tcp->snd_up)) {

That should be "tp->snd_up" instead of "tcp->snd_up". Other than that,
the good news is I've tested your patch on top of Herbert's patch, and
it works! No more rlogin hangs!

Thanks,
Jeff.
