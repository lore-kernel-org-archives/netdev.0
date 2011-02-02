From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 2.6.37 : oops in cleanup_once
Date: Wed, 02 Feb 2011 15:53:27 +0100
Message-ID: <1296658407.20445.19.camel@edumazet-laptop>
References: <4D491B8D.1000107@univ-nantes.fr>
	 <1296643972.20445.9.camel@edumazet-laptop>
	 <1296645887.20445.11.camel@edumazet-laptop>
	 <4D495765.4090806@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D495765.4090806@univ-nantes.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 14:08 +0100, Yann Dupont a =C3=A9=
crit :
> Le 02/02/2011 12:24, Eric Dumazet a =C3=A9crit :
> > Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 11:52 +0100, Eric Dumazet a=
 =C3=A9crit :
> >> Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 09:53 +0100, Yann Dupont a=
 =C3=A9crit :
> >>> Hello.
> >>> We recently upgraded one machine with vanilla 2.6.37, and experie=
nced 2
> >>> kernel oops since. Each oops is after ~1 week of uptime.
> >>> The last oops was last night but we didn't had any trace.
> > oops, 2.6.37 "only"
> >
> >> Yes this is a known problem.
> >>
> >> Please try commit 3408404a4c2a4eead9d73b0bbbfe3f225b65f492
> >> (inetpeer: Use correct AVL tree base pointer in inet_getpeer())
> >>
> >> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git=
;a=3Dcommitdiff;h=3D3408404a4c2a4eead9d73b0bbbfe3f225b65f492
> >>
> >> I believe David will send it to stable team shortly, if not alread=
y
> >> done :)
> > Please ignore, this patch was for linux-2.6 tree, 2.6.37 was not
> > affected by the problem.
> >
> > So its another problem... Is there anything particular you do on th=
is
> > machine ?
> >
> >
> >
> >
> Nothing really special there, we run a lot (20) of KVM guest (mainly=20
> linux firewalls for lots of differents vlan), so we have a lot of=20
> bridges vlan & tun/tap.
> Oh, and CONFIG_BRIDGE_IGMP_SNOOPING is set to n (because of  the othe=
r=20
> bug already sent to netdev - more to come on next mail)
>=20
> Hard to say if this BUG is new in 2.6.37. This host was running fine=20
> with 2.6.34.2 since August 2010.
> Bisecting will be hard due to the time to trigger the bug (and the fa=
ct=20
> that this machine is a production machine)
>=20
> Anyway, I can test with a specific kernel version if you suspect some=
thing.
>=20

I suspect a mem corruption from another layer (not inetpeer)

Unfortunately many kmem caches share the "64 bytes" cache.

Could you please add "slub_nomerge" on your boot command ?


This way, we can separate corruptions on each cache.


On your crash, one inetpeer contain garbage on unused_lists next/prev
pointers :

RCX: 0000000000000005
RDX: 0b000209f1beadde

Definitly something overwrote these values with non pointers values.
