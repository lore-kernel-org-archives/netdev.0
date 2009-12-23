From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 11:44:41 -0500
Message-ID: <4B3248F9.5030504@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig84F1A320DEC7CEDD009FC772"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, Avi Kivity <avi@redhat.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091223065129.GA19600@elte.hu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig84F1A320DEC7CEDD009FC772
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/23/09 1:51 AM, Ingo Molnar wrote:
>=20
> * Anthony Liguori <anthony@codemonkey.ws> wrote:
>=20
>> On 12/22/2009 10:01 AM, Bartlomiej Zolnierkiewicz wrote:
>>>> new e1000 driver is more superior in architecture and do the require=
d
>>>> work to make the new e1000 driver a full replacement for the old one=
=2E
>>> Right, like everyone actually does things this way..
>>>
>>> I wonder why do we have OSS, old Firewire and IDE stacks still around=
 then?
>>
>> And it's always a source of pain, isn't it.
>=20
> Even putting aside the fact that such overlap sucks and is a pain to us=
ers=20
> (and that 98% of driver and subsystem version transitions are done comp=
letely=20
> seemlessly to users - the examples that were cited were the odd ones ou=
t of=20
> 150K commits in the past 4 years, 149K+ of which are seemless), the com=
parison=20
> does not even apply really.
>=20
> e1000, OSS, old Firewire and IDE are hardware stacks, where hardware is=
 a not=20
> fully understood externality, with its inevitable set of compatibility =
voes.=20
> There's often situations where one piece of hardware still works better=
 with=20
> the old driver, for some odd (or not so odd) reason.
>=20
> Also, note that the 'new' hw drivers are generally intended and are mai=
ntained=20
> as clear replacements for the old ones, and do so with minimal ABI chan=
ges -=20
> or preferably with no ABI changes at all. Most driver developers just s=
witch=20
> from old to new and the old bits are left around and are phased out. We=
 phased=20
> out old OSS recently.
>=20
> That is a very different situation from the AlacrityVM patches, which:
>=20
>  - Are a pure software concept

By design.  In fact, I would describe it as "software to software
optimized" as opposed to trying to shoehorn into something that was
designed as a software-to-hardware interface (and therefore has
assumptions about the constraints in that environment that are not
applicable in software-only).

> and any compatibility mismatch is self-inflicted.

=2E. because the old model is not great for the intended use cases and ha=
s
issues.  I've already covered the reasons why adnauseam.

>  The patches are in fact breaking the ABI to KVM intentionally (for bet=
ter or worse).

No, at the very worst they are _augmenting_ the ABI, as evident from the
fact that AlacrityVM is a superset of the entire KVM ABI.

>=20
>  - Gregory claims that the AlacricityVM patches are not a replacement f=
or KVM.
>    I.e. there's no intention to phase out any 'old stuff'=20

There's no reason to phase anything out, except perhaps the virtio-pci
transport.  This is one more transport, plugging into virtio underneath
(just like virtio-pci, virtio-lguest, and virtio-s390).  I am not even
suggesting that the old transport has to go away, per se.  It is the KVM
maintainers who insist on it being all or nothing.  For me, I do not see
the big deal in having one more "model" option in the qemu cmd-line, but
that is just my opinion.  If the maintainers were really so adamant that
choice is pure evil, I am not sure why we don't see patches for removing
everything but one model type in each IO category.  But I digress.

> and it splits the pool of driver developers.

=2E.it these dumb threads that are splitting driver developers with
ignorant statements, irrelevant numbers, and dubious "facts".  I
actually tried many many times to ask others to join the effort, and
instead _they_ forked off and made vhost-net with a "sorry, not
interested in working with you"(and based the design largely on the
ideas proposed in my framework, I might add).  Thats fine, and it's
their prerogative.  I can easily maintain my project out of tree if
upstream is not interested.  But do not turn around and try to blame me
for the current state of affairs.

>=20
> i.e. it has all the makings of a stupid, avoidable, permanent fork. The=
 thing=20
> is, if AlacricityVM is better, and KVM developers are not willing to fi=
x their=20
> stuff, replace KVM with it.
>=20
> It's a bit as if someone found a performance problem with sys_open() an=
d came=20
> up with sys_open_v2() and claimed that he wants to work with the VFS=20
> developers while not really doing so but advances sys_open_v2() all the=
 time.

No, its more like if I suggested sys_open_vbus() to augment
sys_open_pci(), sys_open_lguest(), sys_open_s390() because our
fictitious glibc natively supported modular open() implementations.  And
I tried to work for a very long time convincing the VFS developers that
this new transport was a good idea to add because it was optimized for
the problem space, made it easy for API callers to reuse the important
elements of the design (e.g. built in "tx-mitigation" instead of waiting
for someone to write it for each device), had new features like the
ability to prioritize signals, create/route signal paths arbitrarily,
implement raw shared memory for idempotent updates, and didn't require
the massive and useless PCI/APIC emulation logic to function like
sys_open_pci() (e.g. easier to port around).

Ultimately, the "VFS developers" said "I know we let other transports in
in the past, but now all transports must be sys_open_pci() based going
forward".  Game over, since sys_open_pci cannot support the features I
need, and/or it makes incredibly easy things complex when they don't
need to be so its a poor choice.

>=20
> Do we allow sys_open_v2() upstream, in the name of openness and diversi=
ty,=20
> letting some apps use that syscall while other apps still use sys_open(=
)?

s/sys_open_v2/sys_open_vbus to portray it accurately, and sure, why not?
 There is plenty of precedent already.  Its just the top-edge IO ABI.
You can chose realtek, e1000, virtio-net 802.x ABIs today for instance.
 This is one more, and despite attempts at painting it duplicative, it
is indeed an evolutionary upgrade IMO especially when you glance beyond
the 802.x world and look at the actual device model presented.

And its moot, anyway, as I have already retracted my one outstanding
pull request based on Linus' observation.  So at this time, I am not
advocating _anything_ for upstream inclusion.  And I am contemplating
_never_ doing so again.  It's not worth _this_.

> Or do we say "enough is enough of this stupidity,

I certainly agree that this thread has indeed introduced a significant
degree of stupidity, yes.

> come up with some strong=20
> reasons to replace sys_open, and if so, replace the thing and be done w=
ith the=20
> pain!".
>

I am open to this, but powerless to control the decision in the upstream
variant other than to describe what I did, and rebut FUD against it to
make sure the record is straight.


> Overlap and forking can still be done in special circumstances, when a =
project=20
> splits and a hostile fork is inevitable due to prolongued and irreconci=
lable=20
> differences between the parties

You are certainly a contributing factor in pushing things in that directi=
on.

> and if there's no strong technical advantage
> on either side.  I havent seen evidence of this yet though: Gregory
claims that
> he wants to 'work with the community'

Well, I sincerely did in the beginning in the spirit of FOSS.  I have to
admit that the desire is constantly eroded after dealing with the likes
of you. So if I have seemed more standoffish as of late, that is the
reason.  If that was your goal, congratulations:  You have irritated me
into submission.  And no, I don't expect you to care.

> and the KVM guys seem to agree violently=20
> that performance can be improved - and are doing so (and are asking Gre=
gory to=20
> take part in that effort).

And as I indicated to you in my first reply to this thread: the
performance aspects are but one goal here.  Some of the performance
aspects cannot be achieved with their approach (like EIO mitigation as
an example), and some of the other feature based aspects cannot be
achieved either (interrupt priority, dynamic signals, etc).  That is why
the calls to unify behind virtio-pci have gone unanswered by me: That
approach is orthogonal to the vbus project goals.  Their ability to
understand or agree with that difference has no bearing on whether there
is any technical merit here.  I think this is what you are failing to gra=
sp.

There will be people that will say "Well, we can do a PV-APIC and get
EOI mitigation in PCI too".  THAT IS WHAT VBUS IS FOR!!!   Implementing
linux-kernel backed, shared-memory, high performance devices.  Something
like a shared-memory based interrupt controller would be exactly the
kind of thing I envision here.  We can also do other things, like high
performance timers, scheduler coordinators, etc.  I don't know how many
different ways to describe it in a way that will be understood.  I
started with 802.x because its easy to show the performance gains.  If I
knew that the entire community would get bent around the axle on 802.x
when I started, I never would have broached the subject like this.  Se
la vie.

>=20
> The main difference is that Gregory claims that improved performance is=
 not=20
> possible within the existing KVM framework, while the KVM developers di=
sagree.=20
> The good news is that this is a hard, testable fact.

Yes, I encourage a bakeoff and have code/instructions available to
anyone interested.  I also encourage people to think about the other
facilities that are being introduced in addition to performance
enhancements for simple 802.x, or even KVM.  This is about building a
modular framework that encompasses both sides of the links (guest AND
host), and implements "best practices" for optimized PV IO ingrained in
its DNA.  It tries to do this in such a way that we don't need to write
new backends for every environment that comes along, or rely on
unnecessary emulation layers (PCI/APIC) to achieve it.  It's about
extending Linux as a "io-visor" much as it is for userspace apps for any
environments, using a tried and true shared-memory based approach.

>=20
> I think we should try _much_ harder before giving up and forking the AB=
I of a=20
> healthy project and intentionally inflicting pain on our users.
>=20
> And, at minimum, such kinds of things _have to_ be pointed out in pull =

> requests, because it's like utterly important. In fact i couldnt list a=
ny more=20
> important thing to point out in a pull request.

Mea Culpa.  Since I've already established that the pull request didn't
directly relate to the controversy, I didn't think to mention that at
the time.  These were just a few more drivers to join the ranks of 1000s
more within Linux.  In retrospect, I probably should have so I apologize
for that.  It was my first pull request to Linus, so I was bound to
screw something up.

-Greg


--------------enig84F1A320DEC7CEDD009FC772
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksySPkACgkQP5K2CMvXmqFpbQCZATBvQlI/mBqqPagGYtUfjFy8
xPcAn0u2lj6wc5BEXInjlD2HoaIhegRc
=JloZ
-----END PGP SIGNATURE-----

--------------enig84F1A320DEC7CEDD009FC772--
