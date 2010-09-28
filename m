From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: Correct header retrieval after pskb_may_pull
Date: Wed, 29 Sep 2010 00:23:44 +0300
Message-ID: <201009290023.44717.remi.denis-courmont@nokia.com>
References: <1285665042-20548-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"gulshan.karmani@stericsson.com" <gulshan.karmani@stericsson.com>,
	Linus Walleij <linus.walleij@stericsson.com>
To: ext Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:63776 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344Ab0I1VYD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 17:24:03 -0400
In-Reply-To: <1285665042-20548-1-git-send-email-kumar.sanghvi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 28 September 2010 12:10:42 ext Kumar A Sanghvi, you wrote:
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
>=20
>  	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
>  		return -EINVAL;
>=20
> +	hdr =3D pnp_hdr(skb);
>  	if (hdr->data[0] !=3D PN_PEP_TYPE_COMMON) {
>  		LIMIT_NETDEBUG(KERN_DEBUG"Phonet unknown PEP type: %u\n",
>  				(unsigned)hdr->data[0]);

Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Thanks!

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
