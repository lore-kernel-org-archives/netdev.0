From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: netfilter 07/41: arp_tables: unfold two critical loops in arp_packet_match()
Date: Tue, 24 Mar 2009 22:39:10 +0100
Message-ID: <49C952FE.7070202@cosmosbay.com>
References: <20090324.132954.148903398.davem@davemloft.net> <49C94B6A.5020304@cosmosbay.com> <alpine.LSU.2.00.0903242215590.26397@fbirervta.pbzchgretzou.qr> <20090324.141848.119353425.davem@davemloft.net> <alpine.LSU.2.00.0903242220280.26397@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0903242220280.26397@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt a =E9crit :
> On Tuesday 2009-03-24 22:18, David Miller wrote:
>>>> Arches without efficient unaligned access can still perform a loop
>>>> assuming 16bit alignment in ifname_compare()
>>> Allow me some skepticism, but the code looks pretty much like a
>>> standard memcmp.
>> memcmp() can't make any assumptions about alignment.
>> Whereas we _know_ this thing is exactly 16-bit aligned.
>>
>> All of the optimized memcmp() implementations look for
>> 32-bit alignment and punt to byte at a time comparison
>> loops if things are not aligned enough.
>=20
> Yes, I seem to remember glibc doing something like
>=20
>  if ((addr & 0x03) !=3D 0) {
>      // process single bytes (increment addr as you go)
>      // until addr & 0x03 =3D=3D 0.
>  }
>=20
>  /* optimized loop here. also increases addr */
>=20
>  if ((addr & 0x03) !=3D 0)
>      // still bytes left after loop - process on a per-byte basis
>=20
> Is the cost of testing for non-4-divisibility expensive enough
> to warrant not usnig memcmp?
>=20
> Irrespective of all that, I think putting the interface comparison
> code should be agglomerated in a function/header so that it is
> replicated across iptables, ip6tables, ebtables, arptables, etc.

memcmp() is fine, but how is it solving the masking problem we have ?

Also in the case of arp_tables, _a is long word aligned, while _b and _=
mask are not.

memcmp() in this case is slower, (and dont handle mask thing)

If you look various ifname_compare(), we have two different implementat=
ions.

So yes, a factorization is possible for three ip_tables.c, ip6_tables.c=
 and xt_physdev.c




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
