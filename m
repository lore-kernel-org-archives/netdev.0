From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] pkt_sched: gen_estimator: use 64 bits intermediate	counters
 for bps
Date: Tue, 19 May 2009 20:03:24 +0200
Message-ID: <4A12F46C.4070605@cosmosbay.com>
References: <20090516141430.GB3013@ami.dom.local> <4A118F98.60101@cosmosbay.com> <20090518172349.GA2755@ami.dom.local> <20090518.145233.212710505.davem@davemloft.net> <4A11F67B.3050805@cosmosbay.com> <20090519070252.GA4210@ff.dom.local> <4A126058.7030605@cosmosbay.com> <20090519074247.GB4210@ff.dom.local> <20090519075715.GC4210@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vexwek@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60187 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbZESSDi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 14:03:38 -0400
In-Reply-To: <20090519075715.GC4210@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Tue, May 19, 2009 at 07:42:47AM +0000, Jarek Poplawski wrote:
>> On Tue, May 19, 2009 at 09:31:36AM +0200, Eric Dumazet wrote:
>>> Jarek Poplawski a =E9crit :
>>>> On Tue, May 19, 2009 at 01:59:55AM +0200, Eric Dumazet wrote:
>>>> ...
>>>>> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
>>>> ...
>>>>> -		e->avbps +=3D ((long)rate - (long)e->avbps) >> e->ewma_log;
>>>>> +		e->avbps +=3D ((s64)(brate - e->avbps)) >> e->ewma_log;
>>>> Btw., I'm a bit concerned about the syntax here: isn't such shifti=
ng
>>>> of signed ints implementation dependant?
>>>>
>>> You are right Jarek, I very often forget to never ever use signed q=
uantities
>>> at all ! (But also note original code has same undefined behavior)
>> Sure, I've meant the original code including 5 lines below.
>>
>>> Apparently gcc does the *right* thing on x86_32, but we probably wa=
nt something
>>> stronger here. I could not find gcc documentation statement on righ=
t shifts of=20
>>> negative values.
>> I guess gcc and most of others do this "right"; but it looks
>> "unkosher" anyway.
>=20
> I might have missed your point here, but would it be so costly to do
> these shifts separately here?

You replied to yourself Jarek :)

As I said earlier, I found your concern right, so please submit a patch=
 ?

I found many occurrences of a right shift on a signed int/long in kerne=
l.
One example being :

arch/x86/mm/init_64.c

int kern_addr_valid(unsigned long addr)
{
	unsigned long above =3D ((long)addr) >> __VIRTUAL_MASK_SHIFT;


and another rate estimator in drivers/atm/idt77252.c

static void
idt77252_est_timer(unsigned long data)


We could aso check net/netfilter/ipvs/ip_vs_est.c (estimation_timer())

