From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Phonet: Correct header retrieval after pskb_may_pull
Date: Tue, 28 Sep 2010 11:47:18 +0200
Message-ID: <1285667238.3154.0.camel@edumazet-laptop>
References: <1285665042-20548-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	remi.denis-courmont@nokia.com, gulshan.karmani@stericsson.com,
	Linus Walleij <linus.walleij@stericsson.com>
To: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51060 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758768Ab0I1Jra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 05:47:30 -0400
Received: by fxm3 with SMTP id 3so2455894fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 02:47:29 -0700 (PDT)
In-Reply-To: <1285665042-20548-1-git-send-email-kumar.sanghvi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 septembre 2010 =C3=A0 14:40 +0530, Kumar A Sanghvi a =C3=A9=
crit :
> From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
>=20
> Retrieve the header after doing pskb_may_pull since, pskb_may_pull
> could change the buffer structure.
>=20
> This is based on the comment given by Eric Dumazet on Phonet
> Pipe controller patch for a similar problem.
>=20
> Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
> Acked-by: Linus Walleij <linus.walleij@stericsson.com>
> ---
>  net/phonet/pep.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/phonet/pep.c b/net/phonet/pep.c
> index 7bf23cf..9746c6d 100644
> --- a/net/phonet/pep.c
> +++ b/net/phonet/pep.c
> @@ -507,12 +507,13 @@ static void pipe_grant_credits(struct sock *sk)
>  static int pipe_rcv_status(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct pep_sock *pn =3D pep_sk(sk);
> -	struct pnpipehdr *hdr =3D pnp_hdr(skb);
> +	struct pnpipehdr *hdr;
>  	int wake =3D 0;
> =20
>  	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
>  		return -EINVAL;
> =20
> +	hdr =3D pnp_hdr(skb);
>  	if (hdr->data[0] !=3D PN_PEP_TYPE_COMMON) {
>  		LIMIT_NETDEBUG(KERN_DEBUG"Phonet unknown PEP type: %u\n",
>  				(unsigned)hdr->data[0]);

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


