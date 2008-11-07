From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: introduce read_pnet() and write_pnet() functions
Date: Fri, 07 Nov 2008 18:49:32 +0100
Message-ID: <49147FAC.8070306@cosmosbay.com>
References: <49146265.8040301@cosmosbay.com> <20081107174100.GA3469@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44177 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbYKGRtw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 12:49:52 -0500
In-Reply-To: <20081107174100.GA3469@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan a =E9crit :
> On Fri, Nov 07, 2008 at 04:44:37PM +0100, Eric Dumazet wrote:
>> CONFIG_NET_NS is not a widespread option, we can reduce kernel size
>> not declaring useless "struct net" pointers in several structures.
>=20
> This can be done separatedly for each offending "struct net *".

Sure I can split the patch if you think its too complex. I also can lea=
ve
#ifdef CONFIG_NET_NS all over if you like them.

>=20
>> This patch declares three helper to clean various "ifdef CONFIG_NET_=
NS"
>> that we have in many places.
>=20
> There is an implicit assumption, that all such ifdefs are bad, while =
if fact
> there are nothing wrong with them:

Well... we can hide the ugly details.

Especially with #ifdef in C files.

>=20
> 	#ifdef CONFIG_NET_NS
> 		struct net *ct_net;
> 	#endif
>=20
>> #ifdef CONFIG_NET_NS
>>
>> #define DECLARE_PNET(name) struct net *name;
>=20
> One more macro, instead of immediately understandable thing.

DECLARE_PNET() ?
Did you check DECLARE_RWSEM, DECLARE_WAITQUEUE,=20
DECLARE_PER_CPU, DECLARE_BITMAP ... ???

>=20
>> static inline void write_pnet(struct net **pnet, struct net *net)
>> {
>>        *pnet =3D net;
>> }
>>
>> static inline struct net *read_pnet(struct net * const *pnet)
>> {
>>        return *pnet;
>> }
>> #else
>>
>> #define DECLARE_PNET(name)
>> #define write_pnet(pnet, net)   do { (void)(net);} while (0)
>> #define read_pnet(pnet)         (&init_net)
>>
>> #endif
>>
>> In particular, using these helpers permits a shrink of inet_bind_buc=
ket
>> (16 bytes instead of 32 on 32bit arches, and 32 bytes instead of 64 =
on 64bits)
>=20
> Why not just fix exactly bind bucket issue.

Another #ifdef ?=20

>=20
> As I posted earlier, ->dst_net can go after IPv6 dst_ops can be embed=
ded
> directly into struct netns_ipv6, but header dependencies aren't trivi=
al.
>=20
> As for netns comparisons, use net_eq() to amortize the cost somewhat.
>=20
>=20

I believe all "struct net*" parameter passing could disappear with appr=
opriate macros.

This stuff currently eat a precious register on i386/x86_64/... archite=
ctures.



