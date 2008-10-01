From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/6] Phonet: transport protocol auto-loading
Date: Wed, 1 Oct 2008 09:45:43 -0300
Message-ID: <20081001124543.GD970@ghostprotocols.net>
References: <200810011312.17288.remi.denis-courmont@nokia.com> <1222855985-22859-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38816 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752532AbYJAMrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 08:47:40 -0400
Content-Disposition: inline
In-Reply-To: <1222855985-22859-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Oct 01, 2008 at 01:13:00PM +0300, Remi Denis-Courmont escreveu:
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  net/phonet/af_phonet.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index 1d8df6b..06627d3 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -64,6 +64,11 @@ static int pn_socket_create(struct net *net, struc=
t socket *sock, int protocol)
>  	}
> =20
>  	pnp =3D phonet_proto_get(protocol);
> +#ifdef CONFIG_KMOD
> +	if (pnp =3D=3D NULL
> +	 && request_module("net-pf-%d-proto-%d", PF_PHONET, protocol) =3D=3D=
 0)

&& at the end of previous line, please.

I wonder if we shouldn't have:

net_pf_request_module(PF_PHONET, protocol)

[acme@doppio linux-2.6]$ grep "net-pf-%d-proto-%d" net/*/*.c
net/ipv4/af_inet.c: request_module("net-pf-%d-proto-%d-type-%d",
net/ipv4/af_inet.c: request_module("net-pf-%d-proto-%d",
net/ipv4/inet_diag.c: request_module("net-pf-%d-proto-%d-type-%d", PF_N=
ETLINK,
net/ipv6/af_inet6.c: request_module("net-pf-%d-proto-%d-type-%d",
net/ipv6/af_inet6.c: request_module("net-pf-%d-proto-%d",
net/netlink/af_netlink.c: request_module("net-pf-%d-proto-%d", PF_NETLI=
NK, protocol);
[acme@doppio linux-2.6]$

Nah, perhaps not...


> +		pnp =3D phonet_proto_get(protocol);
> +#endif
>  	if (pnp =3D=3D NULL)
>  		return -EPROTONOSUPPORT;
>  	if (sock->type !=3D pnp->sock_type) {
> --=20
> 1.5.4.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
