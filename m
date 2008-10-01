From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/6] Phonet: transport protocol auto-loading
Date: Wed, 01 Oct 2008 17:01:15 +0200
Message-ID: <1222873275.11272.13.camel@violet.holtmann.net>
References: <200810011312.17288.remi.denis-courmont@nokia.com>
	 <1222855985-22859-1-git-send-email-remi.denis-courmont@nokia.com>
	 <20081001124543.GD970@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
	netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:52195 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbYJAPBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 11:01:16 -0400
In-Reply-To: <20081001124543.GD970@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> > Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.=
com>
> > ---
> >  net/phonet/af_phonet.c |    5 +++++
> >  1 files changed, 5 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> > index 1d8df6b..06627d3 100644
> > --- a/net/phonet/af_phonet.c
> > +++ b/net/phonet/af_phonet.c
> > @@ -64,6 +64,11 @@ static int pn_socket_create(struct net *net, str=
uct socket *sock, int protocol)
> >  	}
> > =20
> >  	pnp =3D phonet_proto_get(protocol);
> > +#ifdef CONFIG_KMOD
> > +	if (pnp =3D=3D NULL
> > +	 && request_module("net-pf-%d-proto-%d", PF_PHONET, protocol) =3D=
=3D 0)
>=20
> && at the end of previous line, please.
>=20
> I wonder if we shouldn't have:
>=20
> net_pf_request_module(PF_PHONET, protocol)
>=20
> [acme@doppio linux-2.6]$ grep "net-pf-%d-proto-%d" net/*/*.c
> net/ipv4/af_inet.c: request_module("net-pf-%d-proto-%d-type-%d",
> net/ipv4/af_inet.c: request_module("net-pf-%d-proto-%d",
> net/ipv4/inet_diag.c: request_module("net-pf-%d-proto-%d-type-%d", PF=
_NETLINK,
> net/ipv6/af_inet6.c: request_module("net-pf-%d-proto-%d-type-%d",
> net/ipv6/af_inet6.c: request_module("net-pf-%d-proto-%d",
> net/netlink/af_netlink.c: request_module("net-pf-%d-proto-%d", PF_NET=
LINK, protocol);
> [acme@doppio linux-2.6]$
>=20
> Nah, perhaps not...

maybe it is not such a bad idea. Every protocol seems to have its own
code in it. I am using this:

#if defined(CONFIG_KMOD)
        if (!bt_proto[proto]) {
                request_module("bt-proto-%d", proto);
        }
#endif

Regards

Marcel


