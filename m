From: Martin Filip <nexus+kernel@smoula.net>
Subject: Re: TUN device performance regression
Date: Mon, 14 Apr 2014 16:51:47 +0200
Message-ID: <1397487107.1625.0.camel@interceptor.in.smoula.net>
References: <1397475118.11864.5.camel@interceptor.in.smoula.net>
	 <1397475759.12568.0.camel@interceptor.in.smoula.net>
	 <534BF402.6010505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scarab.smoula.net ([83.240.14.6]:44639 "EHLO scarab.smoula.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754296AbaDNOvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 10:51:55 -0400
In-Reply-To: <534BF402.6010505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich p=C3=AD=C5=A1e v Po 14. 04. 2014 v 10:43 -0400:
> On 04/14/2014 07:42 AM, Martin Filip wrote:
> >> Hello,
> >>
> >> I've noticed significant TUN device performance drop between 3.13 =
and
> >> 3.14 kernels, problem seems to persist until current git version.
> >>
> >> With good kernel I can achieve full 100mbps through openvpn withou=
t any
> >> problem, with problematic kernel TX performance drops down to ~50k=
bps.
> >>
> >> According to git bisect it seems that root of all evil is commit
> >> 53d6471cef17262d3ad1c7ce8982a234244f68ec.
> >>
> >> I can confirm that performance is great again with current kernel =
when I
> >> revert this one.
> >>
> > I've forgot to mention kernel bug:
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D74051
> >
>=20
> Could you please try this patch.
>=20
> ---
>  net/core/dev.c      | 2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 45fa2f1..6088927 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2289,7 +2289,7 @@ EXPORT_SYMBOL(skb_checksum_help);
>  __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
>  {
>  	__be16 type =3D skb->protocol;
> -	int vlan_depth =3D ETH_HLEN;
> +	int vlan_depth =3D skb->mac_len;
>=20
>  	/* Tunnel gso handlers can set protocol to ethernet. */
>  	if (type =3D=3D htons(ETH_P_TEB)) {

Hello,

thank you for your quick response. This seems to fix the problem, my
test case worked fine with it!

--=20
Martin Filip
e-mail: nexus@smoula.net
jabberID: nexus@smoula.net
http://www.smoula.net
