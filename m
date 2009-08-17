From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 16:17:09 -0400
Message-ID: <4A89BAC5.9040400@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig352F2FD877EE76757DB0C2B7"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757658AbZHQURP@vger.kernel.org>
In-Reply-To: <20090817174142.GA11140@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig352F2FD877EE76757DB0C2B7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Mon, Aug 17, 2009 at 10:14:56AM -0400, Gregory Haskins wrote:
>> Case in point: Take an upstream kernel and you can modprobe the
>> vbus-pcibridge in and virtio devices will work over that transport
>> unmodified.
>>
>> See http://lkml.org/lkml/2009/8/6/244 for details.
>=20
> The modprobe you are talking about would need
> to be done in guest kernel, correct?

Yes, and your point is?  "unmodified" (pardon the psuedo pun) modifies
"virtio", not "guest".  It means you can take an off-the-shelf kernel
with off-the-shelf virtio (ala distro-kernel) and modprobe
vbus-pcibridge and get alacrityvm acceleration.  It is not a design goal
of mine to forbid the loading of a new driver, so I am ok with that
requirement.

>=20
>> OTOH, Michael's patch is purely targeted at improving virtio-net on kv=
m,
>> and its likewise constrained by various limitations of that decision
>> (such as its reliance of the PCI model, and the kvm memory scheme).
>=20
> vhost is actually not related to PCI in any way. It simply leaves all
> setup for userspace to do.  And the memory scheme was intentionally
> separated from kvm so that it can easily support e.g. lguest.
>=20

I think you have missed my point. I mean that vhost requires a separate
bus-model (ala qemu-pci).  And no, your memory scheme is not separated,
at least, not very well.  It still assumes memory-regions and
copy_to_user(), which is very kvm-esque.  Vbus has people using things
like userspace containers (no regions), and physical hardware (dma
controllers, so no regions or copy_to_user) so your scheme quickly falls
apart once you get away from KVM.

Don't get me wrong:  That design may have its place.  Perhaps you only
care about fixing KVM, which is a perfectly acceptable strategy.  Its
just not a strategy that I think is the best approach.  Essentially you
are promoting the proliferation of competing backends, and I am trying
to unify them (which is ironic that this thread started with concerns I
was fragmenting things ;).

The bottom line is, you have a simpler solution that is more finely
targeted at KVM and virtio-networking.  It fixes probably a lot of
problems with the existing implementation, but it still has limitations.

OTOH, what I am promoting is more complex, but more flexible.  That is
the tradeoff.  You can't have both ;) So do not for one second think
that what you implemented is equivalent, because they are not.

In fact, I believe I warned you about this potential problem when you
decided to implement your own version.  I think I said something to the
effect of "you will either have a subset of functionality, or you will
ultimately reinvent what I did".  Right now you are in the subset phase.
 Perhaps someday you will be in the complete-reinvent phase.  Why you
wanted to go that route when I had already worked though the issues is
something perhaps only you will ever know, but I'm sure you had your
reasons.  But do note you could have saved yourself grief by reusing my
already implemented and tested variant, as I politely offered to work
with you on making it meet your needs.

Kind Regards
-Greg


--------------enig352F2FD877EE76757DB0C2B7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqJusUACgkQP5K2CMvXmqHR/gCdH1DtZW+LdYrLbNbxiqfEKu0Z
oGcAnjOqFooeUsEzq8lo3+YjzmOs22H0
=+s+U
-----END PGP SIGNATURE-----

--------------enig352F2FD877EE76757DB0C2B7--
