From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net 1/3] udp_tunnel: Remove redundant udp_tunnel_gro_complete().
Date: Fri, 29 Apr 2016 15:33:48 -0700
Message-ID: <175616E2-FC50-4961-AB5F-43DF5820A833@ovn.org>
References: <1461968887-4993-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34566 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbcD2Wdw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 18:33:52 -0400
Received: by mail-pf0-f196.google.com with SMTP id 145so13832578pfz.1
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 15:33:52 -0700 (PDT)
In-Reply-To: <1461968887-4993-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a two patch series.. I had a third patch which fixed a bug that=
 was already fixed, so I dropped it but failed to generate messages aga=
in, hence the =E2=80=9C[12]/3=E2=80=9D. Sorry for the noise,

  Jarno

> On Apr 29, 2016, at 3:28 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>=20
> The setting of the UDP tunnel GSO type is already performed by
> udp[46]_gro_complete().
>=20
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
> drivers/net/geneve.c     | 2 --
> drivers/net/vxlan.c      | 2 --
> include/net/udp_tunnel.h | 9 ---------
> net/ipv4/fou.c           | 2 --
> 4 files changed, 15 deletions(-)
>=20
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index bc16889..98f1224 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -504,8 +504,6 @@ static int geneve_gro_complete(struct sk_buff *sk=
b, int nhoff,
> 	int gh_len;
> 	int err =3D -ENOSYS;
>=20
> -	udp_tunnel_gro_complete(skb, nhoff);
> -
> 	gh =3D (struct genevehdr *)(skb->data + nhoff);
> 	gh_len =3D geneve_hlen(gh);
> 	type =3D gh->proto_type;
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 1c0fa36..dd2d032 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -616,8 +616,6 @@ out:
> static int vxlan_gro_complete(struct sk_buff *skb, int nhoff,
> 			      struct udp_offload *uoff)
> {
> -	udp_tunnel_gro_complete(skb, nhoff);
> -
> 	return eth_gro_complete(skb, nhoff + sizeof(struct vxlanhdr));
> }
>=20
> diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
> index b831140..a114024 100644
> --- a/include/net/udp_tunnel.h
> +++ b/include/net/udp_tunnel.h
> @@ -106,15 +106,6 @@ static inline struct sk_buff *udp_tunnel_handle_=
offloads(struct sk_buff *skb,
> 	return iptunnel_handle_offloads(skb, type);
> }
>=20
> -static inline void udp_tunnel_gro_complete(struct sk_buff *skb, int =
nhoff)
> -{
> -	struct udphdr *uh;
> -
> -	uh =3D (struct udphdr *)(skb->data + nhoff - sizeof(struct udphdr))=
;
> -	skb_shinfo(skb)->gso_type |=3D uh->check ?
> -				SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
> -}
> -
> static inline void udp_tunnel_encap_enable(struct socket *sock)
> {
> #if IS_ENABLED(CONFIG_IPV6)
> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
> index a39068b..305d9ac 100644
> --- a/net/ipv4/fou.c
> +++ b/net/ipv4/fou.c
> @@ -228,8 +228,6 @@ static int fou_gro_complete(struct sk_buff *skb, =
int nhoff,
> 	int err =3D -ENOSYS;
> 	const struct net_offload **offloads;
>=20
> -	udp_tunnel_gro_complete(skb, nhoff);
> -
> 	rcu_read_lock();
> 	offloads =3D NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offlo=
ads;
> 	ops =3D rcu_dereference(offloads[proto]);
> --=20
> 2.7.4
>=20
