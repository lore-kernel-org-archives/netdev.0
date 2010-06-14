From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip_frag: Remove some atomic ops
Date: Mon, 14 Jun 2010 16:18:04 +0200
Message-ID: <1276525084.2478.92.camel@edumazet-laptop>
References: <1276506144.2478.40.camel@edumazet-laptop>
	 <4C163622.7080003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51099 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754436Ab0FNOSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 10:18:09 -0400
In-Reply-To: <4C163622.7080003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 juin 2010 =C3=A0 22:01 +0800, Shan Wei a =C3=A9crit :
> Eric Dumazet wrote, at 06/14/2010 05:02 PM:
> > Instead of doing one atomic operation per frag, we can factorize th=
em.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> IPv6 netfilter has implemented owns queue to manage/reassemble defrag=
ments.
> So, you miss this one.
>=20

Not exactly missed, its only a different thing :)

I prefer to separate if possible net patches (David) and netfilter ones
(Patrick), because of delay between git trees.

> [PATCH 1/2] netfilter: defrag: remove one redundant atomic ops
>=20
> Instead of doing one atomic operation per frag, we can factorize them=
=2E
> Reported from Eric Dumazet.
>=20
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
>  net/ipv6/netfilter/nf_conntrack_reasm.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfi=
lter/nf_conntrack_reasm.c
> index 6fb8901..bc5b86d 100644
> --- a/net/ipv6/netfilter/nf_conntrack_reasm.c
> +++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
> @@ -442,7 +442,6 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, s=
truct net_device *dev)
>  	skb_shinfo(head)->frag_list =3D head->next;
>  	skb_reset_transport_header(head);
>  	skb_push(head, head->data - skb_network_header(head));
> -	atomic_sub(head->truesize, &nf_init_frags.mem);
> =20
>  	for (fp=3Dhead->next; fp; fp =3D fp->next) {
>  		head->data_len +=3D fp->len;
> @@ -452,8 +451,8 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, s=
truct net_device *dev)
>  		else if (head->ip_summed =3D=3D CHECKSUM_COMPLETE)
>  			head->csum =3D csum_add(head->csum, fp->csum);
>  		head->truesize +=3D fp->truesize;
> -		atomic_sub(fp->truesize, &nf_init_frags.mem);
>  	}
> +	atomic_sub(head->truesize, &nf_init_frags.mem);
> =20
>  	head->next =3D NULL;
>  	head->dev =3D dev;


