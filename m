From: Florian Westphal <fw@strlen.de>
Subject: Re: [Discussion] About over-MTU-sized skb in virtualized env
Date: Wed, 3 Dec 2014 11:50:46 +0100
Message-ID: <20141203105046.GE16959@breakpoint.cc>
References: <547EB029.5010102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>, Thomas Graf <tgraf@suug.ch>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jesse Gross <jesse@nicira.com>,
	Flavio Leitner <fbl@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>, pshelar@nicira.com,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"Du, Fan" <fan.du@intel.com>
To: Du Fan <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:35254 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750932AbaLCKvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 05:51:00 -0500
Content-Disposition: inline
In-Reply-To: <547EB029.5010102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Du Fan <fengyuleidian0615@gmail.com> wrote:
> Sorry for resend this mail, because my company email is rejected by n=
etdev.
>=20
>=20
> Hi Florian
>=20
>  214 static int ip_finish_output_gso(struct sk_buff *skb)
>  215 {
>  216     netdev_features_t features;
>  217     struct sk_buff *segs;
>  218     int ret =3D 0;
>  219
>  220     /* common case: locally created skb or seglen is <=3D mtu */
>  221     if (((IPCB(skb)->flags & IPSKB_FORWARDED) =3D=3D 0) ||
>  222           skb_gso_network_seglen(skb) <=3D ip_skb_dst_mtu(skb))
>  223         return ip_finish_output2(skb);
>=20
> Could you please state _concrete_ reason why locally created skb
> length is =EF=BC=BFalways=EF=BC=BF fitting into MTU size? or why we n=
eeds this
> checking.

We don't "need" this checking.  Its just to avoid skb_gso_network_segle=
n()
computation for the common (local-out) case.

Locally generated GSO packet is not supposed to exceed dst_mtu, as that
is the PMTU discovery start point in absence of lower/learned value.
