From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Sat, 30 Jan 2010 02:40:37 -0500
Message-ID: <1264837237.7499.5.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant>  <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop> <1264836971.7499.4.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752474Ab0A3Hks@vger.kernel.org>
In-Reply-To: <1264836971.7499.4.camel@tonnant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-01-30 at 02:36 -0500, Jon Masters wrote:
> On Sat, 2010-01-30 at 07:58 +0100, Eric Dumazet wrote:
> > Le vendredi 29 janvier 2010 =C3=A0 20:59 -0500, Jon Masters a =C3=A9=
crit :
> > > On Fri, 2010-01-29 at 20:57 -0500, Jon Masters wrote:
> > >=20
> > > > Ah so I should have realized before but I wasn't looking at val=
id values
> > > > for the range of the hashtable yet, nf_conntrack_htable_size is=
 getting
> > > > wildly out of whack. It goes from:
> > > >=20
> > > > (gdb) print nf_conntrack_hash_rnd
> > > > $1 =3D 2688505299
> > > > (gdb) print nf_conntrack_htable_size
> > > > $2 =3D 16384
> > > >=20
> > > > nf_conntrack_events: 1
> > > > nf_conntrack_max: 65536
> > > >=20
> > > > Shortly after booting, before being NULLed shortly after starti=
ng some
> > > > virtual machines (the hash isn't reset, whereas it is recompute=
d if the
> > > > hashtable is re-initialized after an intentional resizing opera=
tion):
> > >=20
> > > I mean the *seed* isn't changed, so I don't think it was resized
> > > intentionally. I wonder where else htable_size is fiddled with.
>=20
> > This rings a bell here, since another crash analysis on another pro=
blem
> > suggested to me a potential problem with read_mostly and modules, b=
ut I
> > had no time to confirm the thing yet.
> >=20
> > Could you try changing
> >=20
> >=20
> > net/netfilter/nf_conntrack_core.c:57:unsigned int nf_conntrack_htab=
le_size __read_mostly;
> > to
> > net/netfilter/nf_conntrack_core.c:57:unsigned int nf_conntrack_htab=
le_size ;
>=20
> I'll play later. Right now, I'm looking over every iptables/ip call
> libvirt makes - it explicitly plays with the netns for the loopback,
> which looks interesting. Supposing it does cause the hashtables to ge=
t
> unintentionally zereod or the sizing to get wiped out, we should also
> nonetheless catch the case that the hash function generates a whacko
> number or that the hash size is set to zero when we want to use it.

Oh, btw, it's definitely a localized corruption, I did memory dumps of
the offending page before and after - it's only the two hashing sizes
that get screwed around with, so it's "intentional".

Jon.
