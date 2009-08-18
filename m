From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Tue, 18 Aug 2009 11:19:40 -0400
Message-ID: <4A8AC68C.6040308@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC642A6578DDFAC710B476427"
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090818084606.GA13878@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC642A6578DDFAC710B476427
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Mon, Aug 17, 2009 at 04:17:09PM -0400, Gregory Haskins wrote:
>> Michael S. Tsirkin wrote:
>>> On Mon, Aug 17, 2009 at 10:14:56AM -0400, Gregory Haskins wrote:
>>>> Case in point: Take an upstream kernel and you can modprobe the
>>>> vbus-pcibridge in and virtio devices will work over that transport
>>>> unmodified.
>>>>
>>>> See http://lkml.org/lkml/2009/8/6/244 for details.
>>> The modprobe you are talking about would need
>>> to be done in guest kernel, correct?
>> Yes, and your point is? "unmodified" (pardon the psuedo pun) modifies
>> "virtio", not "guest".
>>  It means you can take an off-the-shelf kernel
>> with off-the-shelf virtio (ala distro-kernel) and modprobe
>> vbus-pcibridge and get alacrityvm acceleration.
>=20
> Heh, by that logic ksplice does not modify running kernel either :)

Sigh...this is just fud.

Again, I never said I do not modify the guest.  I only said that virtio
is unmodified and all the existing devices can work unmodified.

I hardly think its fair to compare something like loading a pci-bridge
driver into a running kernel is the same as patching the kernel.  You
just load a driver to get access to your IO resources...standard stuff
really.

>=20
>> It is not a design goal of mine to forbid the loading of a new driver,=

>> so I am ok with that requirement.
>>
>>>> OTOH, Michael's patch is purely targeted at improving virtio-net on =
kvm,
>>>> and its likewise constrained by various limitations of that decision=

>>>> (such as its reliance of the PCI model, and the kvm memory scheme).
>>> vhost is actually not related to PCI in any way. It simply leaves all=

>>> setup for userspace to do.  And the memory scheme was intentionally
>>> separated from kvm so that it can easily support e.g. lguest.
>>>
>> I think you have missed my point. I mean that vhost requires a separat=
e
>> bus-model (ala qemu-pci).
>=20
> So? That can be in userspace, and can be anything including vbus.

-ENOPARSE

Can you elaborate?

>=20
>> And no, your memory scheme is not separated,
>> at least, not very well.  It still assumes memory-regions and
>> copy_to_user(), which is very kvm-esque.
>=20
> I don't think so: works for lguest, kvm, UML and containers

kvm _esque_ , meaning anything that follows the region+copy_to_user
model.  Not all things do.

>=20
>> Vbus has people using things
>> like userspace containers (no regions),
>=20
> vhost by default works without regions

Thats a start, but not good enough if you were trying to achieve the
same thing as vbus.  As I said before, I've never said you had to
achieve the same thing, but do note they are distinctly different with
different goals.  You are solving a directed problem.  I am solving a
general problem, and trying to solve it once.

>=20
>> and physical hardware (dma
>> controllers, so no regions or copy_to_user) so your scheme quickly fal=
ls
>> apart once you get away from KVM.
>=20
> Someone took a driver and is building hardware for it ... so what?

What is your point?

>=20
>> Don't get me wrong:  That design may have its place.  Perhaps you only=

>> care about fixing KVM, which is a perfectly acceptable strategy.
>> Its just not a strategy that I think is the best approach.  Essentiall=
y you
>> are promoting the proliferation of competing backends, and I am trying=

>> to unify them (which is ironic that this thread started with concerns =
I
>> was fragmenting things ;).
>=20
> So, you don't see how venet fragments things? It's pretty obvious ...

I never said it doesn't.  venet started as a test harness, but now it is
inadvertently fragmenting the virtio-net effort.  I admit it.  It wasn't
intentional, but just worked out that way.  Until your vhost idea is
vetted and benchmarked, its not even in the running.  Venet is currently
the highest performing 802.x acceleration for KVM that I am aware of, so
it will continue to garner interest from users concerned with performance=
=2E

But likewise, vhost has the potential to fragment the back-end model.
That was my point.

>=20
>> The bottom line is, you have a simpler solution that is more finely
>> targeted at KVM and virtio-networking.  It fixes probably a lot of
>> problems with the existing implementation, but it still has limitation=
s.
>>
>> OTOH, what I am promoting is more complex, but more flexible.  That is=

>> the tradeoff.  You can't have both ;)
>=20
> We can. connect eventfds to hypercalls, and vhost will work with vbus.

-ENOPARSE

vbus doesnt use hypercalls, and I do not see why or how you would
connect two backend models together like this.  Can you elaborate.

>=20
>> So do not for one second think
>> that what you implemented is equivalent, because they are not.
>>
>> In fact, I believe I warned you about this potential problem when you
>> decided to implement your own version.  I think I said something to th=
e
>> effect of "you will either have a subset of functionality, or you will=

>> ultimately reinvent what I did".  Right now you are in the subset phas=
e.
>=20
> No. Unlike vbus, vhost supports unmodified guests and live migration.

By "subset", I am referring to your interfaces and the scope of its
applicability.  The things you need to do to make vhost work and a vbus
device work from a memory and signaling abstration POV are going to be
extremely similar.

The difference in how the guest sees them these backends is all
contained in the vbus-connector.  Therefore, what you *could* have done
is simply written a connector that  does something like only support
"virtio" backends, and surfaced them as regular PCI devices to the
guest.  Then you could have reused all the abstraction features in vbus,
instead of reinventing them (case in point, your region+copy_to_user
code).  And likewise, anyone using vbus could use your virtio-net backend=
=2E

Instead, I am still left with no virtio-net backend implemented, and you
were left designing, writing, and testing facilities that I've already
completed.  So it was duplicative effort.

Kind Regards,
-Greg


--------------enigC642A6578DDFAC710B476427
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqKxowACgkQP5K2CMvXmqFL5wCdHmpS5ZjKuu/5W8fgGnmVL3Ub
5wIAnAqvnsJUEKc3XDa1PNscsPuuqcF1
=KHY2
-----END PGP SIGNATURE-----

--------------enigC642A6578DDFAC710B476427--
