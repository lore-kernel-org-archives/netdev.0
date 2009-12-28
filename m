From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] tcp: for tcp westwood implementation
Date: Mon, 28 Dec 2009 12:32:02 +0000
Message-ID: <20091228123202.GA8435@ff.dom.local>
References: <39ba5b880912272235k3f9c4892gf02a727c8ddfc551@mail.gmail.com> <20091228084313.GA7302@ff.dom.local> <39ba5b880912280252y208eb8bby7b54289fcd3965af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:63848 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbZL1McJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 07:32:09 -0500
Received: by fxm25 with SMTP id 25so4524938fxm.21
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2009 04:32:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <39ba5b880912280252y208eb8bby7b54289fcd3965af@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2009 at 07:52:23PM +0900, Jae-Hyun Hwang wrote:
> Is it still wrong?
> I hope this patch is successful.

I hope too, but it depends on David. This time it's mostly OK, execept
"Content-Transfer-Encoding: quoted-printable" instead of "inline", as
required by Documentation/SubmittingPatches.

Jarek P.

PS: Btw, don't leave old information after the patch (next time).

>=20
> From: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>
>=20
> Current net/ipv4/tcp_westwood.c seems to be unnatural when compared
> with Westwood papers.
> Since Linux TCP calls '.ssthresh' interface whenever packet loss is
> detected, it is more natural that the interface points to
> 'tcp_westwood_bw_rttmin' function, not Reno's function.
> This patch also enables Westwood to perform its algorithm when
> CA_EVENT_LOSS event is generated as explained in the papers.
>=20
> Signed-off-by: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>
>=20
> ---
>=20
> --- linux-2.6.32.2/net/ipv4/tcp_westwood.c.orig	2009-12-28
> 13:35:42.000000000 +0900
> +++ linux-2.6.32.2/net/ipv4/tcp_westwood.c	2009-12-28 13:36:54.000000=
000 +0900
> @@ -232,12 +232,7 @@ static void tcp_westwood_event(struct so
>  		westwood_fast_bw(sk);
>  		break;
>=20
> -	case CA_EVENT_COMPLETE_CWR:
> -		tp->snd_cwnd =3D tp->snd_ssthresh =3D tcp_westwood_bw_rttmin(sk);
> -		break;
> -
>  	case CA_EVENT_FRTO:
> -		tp->snd_ssthresh =3D tcp_westwood_bw_rttmin(sk);
>  		/* Update RTT_min when next ack arrives */
>  		w->reset_rtt_min =3D 1;
>  		break;
> @@ -274,9 +269,8 @@ static void tcp_westwood_info(struct soc
>=20
>  static struct tcp_congestion_ops tcp_westwood =3D {
>  	.init		=3D tcp_westwood_init,
> -	.ssthresh	=3D tcp_reno_ssthresh,
> +	.ssthresh	=3D tcp_westwood_bw_rttmin,
>  	.cong_avoid	=3D tcp_reno_cong_avoid,
> -	.min_cwnd	=3D tcp_westwood_bw_rttmin,
>  	.cwnd_event	=3D tcp_westwood_event,
>  	.get_info	=3D tcp_westwood_info,
>  	.pkts_acked	=3D tcp_westwood_pkts_acked,
> --
>=20
>=20
>=20
> On Mon, Dec 28, 2009 at 5:43 PM, Jarek Poplawski <jarkao2@gmail.com> =
wrote:
> > On 28-12-2009 07:35, Jae-Hyun Hwang wrote:
> >> I'm sorry about posting such a damaged email.
> >> I resubmit the patch by plain-text.
> >
> > Most probably it's still wrong (e.g. no tabs).
> > http://marc.info/?l=3Dlinux-netdev&m=3D126198215600946&q=3Draw
> >
> > Did you try to send it to yourself?
> >
> > Jarek P.
> >
> >>
> >> On Mon, Dec 28, 2009 at 2:56 PM, David Miller <davem@davemloft.net=
> wrote:
> >> - Hide quoted text -
> >>> Annyoung-haseyo,
> >>>
> >>> Your patch was damaged by your email client (long lines
> >>> were chopped up with newlines, etc.), as such it is not
> >>> usable.
> >>>
> >>> Please fix this up and resubmit your patch.
> >>>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
> >>
> >
> >
> >
> >
