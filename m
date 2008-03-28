From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.26 2/6][NETNS][SOCK]: Introduce per-net inuse
 counters.
Date: Fri, 28 Mar 2008 10:18:47 +0300
Message-ID: <47EC9BD7.8060304@openvz.org>
References: <47EB550B.8070401@openvz.org> <47EB5711.8040705@openvz.org> <47EC01AE.9010402@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40576 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbYC1HTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 03:19:04 -0400
In-Reply-To: <47EC01AE.9010402@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Pavel Emelyanov a =E9crit :
>> This is probably the most controversial part of the set.
>>
>> The counters are stored in a per-cpu array on a struct net. To=20
>> index in this array the prot->inuse is declared as int and used.=20
>>
>> Numbers (indices) to protos are generated with the appropriate=20
>> enum. I though about using some existing IPPROTO_XXX numbers for
>> protocols but they were too large (IPPROTO_RAW is 255) and did=20
>> not differ for ipv4 and ipv6 (there's no IP6PROTO_RAW, etc).
>>
>> The sock_prot_inuse_(add|get) now use the net argument to
>> get the counter, but this all hides under CONFIG_NET_NS.
>>
>> The sock_prot_inuse_(init|fini) are no-ops. DEFINE_PROTO_INUSE
>> is empty and REF_PROTO_INUSE assigns an index to a proto.
>>
>>  =20
>=20
> Given that :
>=20
> 1) pcounter should really go away from kernel, since Andrew disagree=20
> with the implementation.

Does this and ... (below)

> 2) the need to enumerate all protocols in your enum, it seems ... ugl=
y :)

Yup :(

> 3) alloc_percpu(struct net_prot_inuse) per net is nice because we don=
t=20
> waste memory (if we had to use percpu_counters for each proto for exa=
mple)
>=20
> I suggest to :
>=20
> 1) not use pcounter anymore

=2E.. this mean that I can rework the inuse accounting in order not
to use pcounters at all even with CONFIG_NET_NS=3Dn? :)

> 2) change 'inuse' field to 'inuse_idx' or 'prot_num' that is=20
> automatically allocated at proto_register time, instead statically at=
=20
> compile time.

Hm... I like this approach. Will do.

> Just provide a big enough NET_INUSE_NR (might depend on IPV6 present =
or=20
> not, static or module) to take into account all possible protocols.

Well, I though about this, but wasn't sure whether such heuristics
would be accepted.=20

> struct net_prot_inuse {
> 	int val[NET_INUSE_NR];
> };
>=20
>=20
