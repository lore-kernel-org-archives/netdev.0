From: David Miller <davem@davemloft.net>
Subject: Re: net/sched/act_nat.c BUG
Date: Fri, 09 Jul 2010 17:00:18 -0700 (PDT)
Message-ID: <20100709.170018.189701063.davem@davemloft.net>
References: <201007091637.57660.rpartearroyo@albentia.com>
	<1278688420.2696.7.camel@edumazet-laptop>
	<20100709232359.GA2501@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, rpartearroyo@albentia.com,
	linux-kernel@vger.kernel.org, ipichel@albentia.com,
	nmoron@albentia.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100709232359.GA2501@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 10 Jul 2010 07:23:59 +0800

> On Fri, Jul 09, 2010 at 05:13:40PM +0200, Eric Dumazet wrote:
>> Le vendredi 09 juillet 2010 =E0 16:37 +0200, Rodrigo Partearroyo Gon=
z=E1lez
>> a =E9crit :
>> > Hi all,
>> >=20
>> > I have been testing Stateless NAT and found that ICMP packets with=
 length less=20
>> > than 20 bytes were not correctly NAT'ed. I have found a BUG that m=
akes taking=20
>> > into account IP header length twice, so ICMP packets smaller than =
20 bytes=20
>> > were being dropped.
>> >=20
>>=20
>> CC netdev
>>=20
>> > The proposed fix is:
>> >=20
>> > Index: net/sched/act_nat.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- net/sched/act_nat.c
>> > +++ net/sched/act_nat.c
>> > @@ -202,7 +202,7 @@
>> >         {
>> >                 struct icmphdr *icmph;
>> > =20
>> > -               if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + siz=
eof(*iph)))
>> > +               if (!pskb_may_pull(skb, ihl + sizeof(*icmph)))
>> >                         goto drop;
>> > =20
>> >                 icmph =3D (void *)(skb_network_header(skb) + ihl);
>> >=20
>> > Please, consider applying it.
>>=20
>> Nice catch, but take a look at next lines too,
>> when call to skb_clone_writable() is done, since same error is prese=
nt.
>>=20
>> 	skb_clone_writable(skb,
>> 			   ihl + sizeof(*icmph) + sizeof(*iph))
>>=20
>> Please submit a formal patch, with your "Signed-off-by: ...", as
>> documented in Documentation/SubmittingPatches
>=20
> No we do need the second IP header, think about it...
>=20
> However, we should only drop it only if it's long enough and
> pskb_may_pull fails.

Ok, I've reverted until we come up with the proper fix, thanks.
