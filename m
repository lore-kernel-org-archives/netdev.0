From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 01:36:14 -0400
Message-ID: <4A8B8F4E.80207@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818165139.GC19846@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF95BA0A5EA314A08DECFCBDB"
Cc: Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751303AbZHSFgT@vger.kernel.org>
In-Reply-To: <20090818165139.GC19846@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF95BA0A5EA314A08DECFCBDB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Tue, Aug 18, 2009 at 11:51:59AM -0400, Gregory Haskins wrote:
>>> It's not laughably trivial when you try to support the full feature s=
et
>>> of kvm (for example, live migration will require dirty memory trackin=
g,
>>> and exporting all state stored in the kernel to userspace).
>> Doesn't vhost suffer from the same issue?  If not, could I also apply
>> the same technique to support live-migration in vbus?
>=20
> vhost does this by switching to userspace for the duration of live
> migration. venet could do this I guess, but you'd need to write a
> userspace implementation. vhost just reuses existing userspace virtio.
>=20
>> With all due respect, I didnt ask you do to anything, especially not
>> abandon something you are happy with.
>>
>> All I did was push guest drivers to LKML.  The code in question is
>> independent of KVM, and its proven to improve the experience of using
>> Linux as a platform.  There are people interested in using them (by
>> virtue of the number of people that have signed up for the AlacrityVM
>> list, and have mailed me privately about this work).
>>
>> So where is the problem here?
>=20
> If virtio net in guest could be improved instead, everyone would
> benefit.

So if I whip up a virtio-net backend for vbus with a PCI compliant
connector, you are happy?


> I am doing this, and I wish more people would join.  Instead,
> you change ABI in a incompatible way.

Only by choice of my particular connector.  The ABI is a function of the
connector design.  So one such model is to terminate the connector in
qemu, and surface the resulting objects as PCI devices.  I choose not to
use this particular design for my connector that I am pushing upstream
because I am of the opinion that I can do better by terminating it in
the guest directly as a PV optimized bus.  However, both connectors can
theoretically coexist peacefully.

The advantage that this would give us is that one in-kernel virtio-net
model could be surfaced to all vbus users (pci, or otherwise), which
will hopefully be growing over time.  This would have gained vbus a
virtio-net backend, and it would have saved you from re-inventing the
various abstractions and management interfaces that vbus has in place.


> So now, there's no single place to
> work on kvm networking performance. Now, it would all be understandable=

> if the reason was e.g. better performance. But you say yourself it
> isn't.

Actually, I really didn't say that.  As far as I know, your patch hasnt
been performance proven to my knowledge, but I just gave you the benefit
of the doubt.  What I said was that for a limited type of benchmark, it
*may* get similar numbers if you implemented vhost optimally.  For
others (for instance, when we can start to take advantage of priority,
or scaling the number of interfaces) it may not since my proposed
connector was designed to optimize this over raw PCI facilities.

But I digress.  Please post results when you have numbers, as I had to
give up my 10GE rig in the lab.  I suspect you will have performance
issues until you at least address GSO, but you may already be there by no=
w.

Kind Regards,
-Greg




--------------enigF95BA0A5EA314A08DECFCBDB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqLj04ACgkQP5K2CMvXmqHGHQCffNBx0TXfwnGN1YsgFgSfgNy3
kxoAn05/mIJwgFLlPHJdVnuq0Wfeya+N
=X2GY
-----END PGP SIGNATURE-----

--------------enigF95BA0A5EA314A08DECFCBDB--
