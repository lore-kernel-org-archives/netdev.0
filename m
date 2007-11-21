From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC PATCH 2/2] [TCP] MTUprobe: Cleanup send queue check (no
 need to loop)
Date: Wed, 21 Nov 2007 11:25:07 -0500
Message-ID: <47445BE3.6030708@psc.edu>
References: <11956608882424-git-send-email-ilpo.jarvinen@helsinki.fi> <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi> <1195660888907-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:54843 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756442AbXKUQpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 11:45:20 -0500
In-Reply-To: <1195660888907-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> The original code has striking complexity to perform a query
> which can be reduced to a very simple compare.
>=20
> FIN seqno may be included to write_seq but it should not make
> any significant difference here compared to skb->len which was
> used previously. One won't end up there with SYN still queued.
>=20
> Use of write_seq check guarantees that there's a valid skb in
> send_head so I removed the extra check.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Acked-by: John Heffner <jheffner@psc.edu>


> ---
>  net/ipv4/tcp_output.c |    7 +------
>  1 files changed, 1 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index ff22ce8..1822ce6 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1315,12 +1315,7 @@ static int tcp_mtu_probe(struct sock *sk)
>  	}
> =20
>  	/* Have enough data in the send queue to probe? */
> -	len =3D 0;
> -	if ((skb =3D tcp_send_head(sk)) =3D=3D NULL)
> -		return -1;
> -	while ((len +=3D skb->len) < size_needed && !tcp_skb_is_last(sk, sk=
b))
> -		skb =3D tcp_write_queue_next(sk, skb);
> -	if (len < size_needed)
> +	if (tp->write_seq - tp->snd_nxt < size_needed)
>  		return -1;
> =20
>  	if (tp->snd_wnd < size_needed)

