From: Peter Dawson <petedaws@gmail.com>
Subject: Re: [PATCH v3] ip6_tunnel: Correct tos value in collect_md mode
Date: Sun, 18 Jun 2017 21:06:00 +1000
Message-ID: <20170618210600.0b2dfec5@udesktop>
References: <1497670685-3118-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35358 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdFRLGR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 07:06:17 -0400
In-Reply-To: <1497670685-3118-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Jun 2017 11:38:05 +0800
Haishuang Yan <yanhaishuang@cmss.chinamobile.com> wrote:

> Same as ip_gre, geneve and vxlan, use key->tos as traffic class value.
>=20
> CC: Peter Dawson <petedaws@gmail.com>
> Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on
> encapsulated packets=E2=80=9D)
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>=20
> ---
> Changes since v3:
>   * Add fixes information
>   * Remove obsoleted RT_TOS mask
> ---
>  net/ipv6/ip6_tunnel.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index ef99d59..9d65918 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1249,7 +1249,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_de=
vice *dev, __u8 dsfield,
>  		fl6.flowi6_proto =3D IPPROTO_IPIP;
>  		fl6.daddr =3D key->u.ipv6.dst;
>  		fl6.flowlabel =3D key->label;
> -		dsfield =3D ip6_tclass(key->label);
> +		dsfield =3D  key->tos;
>  	} else {
>  		if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
>  			encap_limit =3D t->parms.encap_limit;
> @@ -1320,7 +1320,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_de=
vice *dev, __u8 dsfield,
>  		fl6.flowi6_proto =3D IPPROTO_IPV6;
>  		fl6.daddr =3D key->u.ipv6.dst;
>  		fl6.flowlabel =3D key->label;
> -		dsfield =3D ip6_tclass(key->label);
> +		dsfield =3D key->tos;
>  	} else {
>  		offset =3D ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
>  		/* ip6_tnl_parse_tlv_enc_lim() might have reallocated skb->head */

Acked-by: Peter Dawson <peter.a.dawson@boeing.com>
