From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Mon, 27 Apr 2009 14:40:54 -0700
Message-ID: <20090427144054.1fb9b7a6@nehalam>
References: <49F22465.80305@gmail.com>
	<20090425133052.4cb711f5@nehalam>
	<49F4A6E3.7080102@cosmosbay.com>
	<20090426185646.GB29238@Krystal>
	<20090426145746.1184aeba@nehalam>
	<1240854297.7620.65.camel@twins>
	<20090427113010.5e3f1700@nehalam>
	<20090427185423.GC23862@elte.hu>
	<20090427120658.35a858bb@nehalam>
	<alpine.LFD.2.00.0904271219570.22156@localhost.localdomain>
	<20090427203616.GB3836@ioremap.net>
	<alpine.LFD.2.00.0904271340400.22156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904271340400.22156@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Apr 2009 13:58:48 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

>=20
>=20
> On Tue, 28 Apr 2009, Evgeniy Polyakov wrote:
> >=20
> > Just ot be sure readers will not lose the discssion topic: do you o=
bject
> > against naming or realizaion?
>=20
> I said _long_ ago that I thought the patch was fine.=20
>=20
> What I object to is people mis-representing the lock, and apparently=20
> having a really hard time admitting that having a good grounding in=20
> networking doesn't necessarily mean that you know everything about=20
> something as basic as locking.
>=20
> > If its about the former, does 'dog's breath lock' proposed by Steph=
en=20
> > fit?
>=20
> Is that just an attempt to avoid admitting that they were wrong about=
 lock=20
> naming? And then trying to trivialize it by calling things by a=20
> _different_ wrong name, but silly enough that they hope people won't =
call=20
> them on it?

The part that concerns me is that the reader lock used in a nested mann=
er on
same cpu may still be broken on -rt. Other than that it is just languag=
e
lawyering; violent agreement that the lock gets used multiple times by
same CPU. I never had the occasion to address this before
(and avoided such usage), but this legacy code exists and needs to
be dealt with.


> Why not just use the correct name? I think it was Mathieu that just=20
> suggested:
>=20
> 	[PATCH] netfilter: use bh disabling with per-cpu read-write lock
>=20
> or just call it "netfilter: use per-CPU read-write lock".

[PATCH] netfilter: Ceci n'est pas une serrure r=C3=A9currente

I don't care. I don't care. Don't you get the point yet.



>=20
> Why are people so against calling things by their correct names? Why =
do=20
> certain network people seem to force a stupid and incorrect descripti=
on,=20
> when they have been told (a) that it's wrong and (b) why it's wrong=20
> several times?

Because meaning comes from context, and my meaning comes from different
context. So we disagree on correct names.=20

> What's so hard with just doing the TechnicallyRightThing(tm) and=20
> describing it as such?
>=20
> And btw - don't get me wrong. There are _other_ ways to do that locki=
ng=20
> too. You don't have to use a rwlock. You can do it with explicit coun=
ting,=20
> the way Eric's original patch did. But it would be wrong to call that=
 one=20
> "recursive lock" too.
>=20
> Or you _could_ use a recursive lock, but nobody has actually posted s=
uch=20
> patches. It would work. No question about it. And if it actually _wer=
e_ a=20
> recursive lock, I wouldn't have objected about the description saying=
 it=20
> is (although I would probably have objected to it being unnecessarily=
=20
> complex, when a simpler rwlock or the explicit count thing would be=20
> sufficient).
>=20
> But since the current simple patch is using a rwlock, why not just sa=
y=20
> that? Why call it something incorrect ("recursive lock") or nonsensic=
al=20
> ("dog's breath lock").
>=20
> As I tried to explain with an analogy, networking people would (quite=
=20
> correctly) object to me calling a serial line an "ethernet cable". Wh=
y is=20
> it so hard for netfilter people to then see why it's wrong to call a=20
> rwlock a "recursive lock".
>=20
> I mean, guys, if you don't want to read up on decades of locking work=
,=20
> just google for it. Google for "recursive lock" (_with_ the quotes). =
At=20
> least for me, the very first hit gives a reasonable explanation for i=
t,=20
> and it says:
>=20
>   "POSIX allows mutexes to be recursive. That means the same thread c=
an=20
>    lock the same mutex twice and won't deadlock."
>=20
> and realize that the "same thread" part is very much a keyword, not j=
uat=20
> a random implementation detail (the first answer to the question is=20
> better than the question, but even the question at the top really doe=
s=20
> get at the basics).
>=20
> And please do realize that neither rwlocks nor the counting locks fro=
m=20
> Dumazet's original patch do that. Never did. They simply aren't recur=
sive=20
> locks.
>=20
> So just don't call them that. But is "dog's breath" any better? Yes, =
maybe=20
> it's less _misleading_, but it sure as hell isn't any more descriptiv=
e.
>=20
> 			Linus
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
