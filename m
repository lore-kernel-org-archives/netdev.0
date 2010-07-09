From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/sched/act_nat.c BUG
Date: Fri, 09 Jul 2010 17:13:40 +0200
Message-ID: <1278688420.2696.7.camel@edumazet-laptop>
References: <201007091637.57660.rpartearroyo@albentia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Iratxo Pichel Ortiz <ipichel@albentia.com>,
	Noelia =?ISO-8859-1?Q?Mor=F3n?= <nmoron@albentia.com>,
	netdev <netdev@vger.kernel.org>
To: Rodrigo Partearroyo =?ISO-8859-1?Q?Gonz=E1lez?=
	<rpartearroyo@albentia.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201007091637.57660.rpartearroyo@albentia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 09 juillet 2010 =C3=A0 16:37 +0200, Rodrigo Partearroyo Gon=
z=C3=A1lez
a =C3=A9crit :
> Hi all,
>=20
> I have been testing Stateless NAT and found that ICMP packets with le=
ngth less=20
> than 20 bytes were not correctly NAT'ed. I have found a BUG that make=
s taking=20
> into account IP header length twice, so ICMP packets smaller than 20 =
bytes=20
> were being dropped.
>=20

CC netdev

> The proposed fix is:
>=20
> Index: net/sched/act_nat.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net/sched/act_nat.c
> +++ net/sched/act_nat.c
> @@ -202,7 +202,7 @@
>         {
>                 struct icmphdr *icmph;
> =20
> -               if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof=
(*iph)))
> +               if (!pskb_may_pull(skb, ihl + sizeof(*icmph)))
>                         goto drop;
> =20
>                 icmph =3D (void *)(skb_network_header(skb) + ihl);
>=20
> Please, consider applying it.

Nice catch, but take a look at next lines too,
when call to skb_clone_writable() is done, since same error is present.

	skb_clone_writable(skb,
			   ihl + sizeof(*icmph) + sizeof(*iph))

Please submit a formal patch, with your "Signed-off-by: ...", as
documented in Documentation/SubmittingPatches

Thanks
