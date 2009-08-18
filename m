From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Tue, 18 Aug 2009 11:39:25 -0400
Message-ID: <4A8ACB2D.9060108@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <20090818095313.GC13878@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig61D0CCB6CF544BBB82BE2776"
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090818095313.GC13878@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig61D0CCB6CF544BBB82BE2776
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Mon, Aug 17, 2009 at 03:33:30PM -0400, Gregory Haskins wrote:
>> There is a secondary question of venet (a vbus native device) verses
>> virtio-net (a virtio native device that works with PCI or VBUS).  If
>> this contention is really around venet vs virtio-net, I may possibly
>> conceed and retract its submission to mainline.
>=20
> For me yes, venet+ioq competing with virtio+virtqueue.
>=20
>> I've been pushing it to date because people are using it and I don't
>> see any reason that the driver couldn't be upstream.
>=20
> If virtio is just as fast, they can just use it without knowing it.
> Clearly, that's better since we support virtio anyway ...

More specifically: kvm can support whatever it wants.  I am not asking
kvm to support venet.

If we (the alacrityvm community) decide to keep maintaining venet, _we_
will support it, and I have no problem with that.

As of right now, we are doing some interesting things with it in the lab
and its certainly more flexible for us as a platform since we maintain
the ABI and feature set.  So for now, I do not think its a big deal if
they both co-exist, and it has no bearing on KVM upstream.

>=20
>> -- Issues --
>>
>> Out of all this, I think the biggest contention point is the design of=

>> the vbus-connector that I use in AlacrityVM (Avi, correct me if I am
>> wrong and you object to other aspects as well).  I suspect that if I h=
ad
>> designed the vbus-connector to surface vbus devices as PCI devices via=

>> QEMU, the patches would potentially have been pulled in a while ago.
>>
>> There are, of course, reasons why vbus does *not* render as PCI, so th=
is
>> is the meat of of your question, I believe.
>>
>> At a high level, PCI was designed for software-to-hardware interaction=
,
>> so it makes assumptions about that relationship that do not necessaril=
y
>> apply to virtualization.
>=20
> I'm not hung up on PCI, myself.  An idea that might help you get Avi
> on-board: do setup in userspace, over PCI.

Note that this is exactly what I do.

In AlacrityVM, the guest learns of the available acceleration by the
presence of the PCI-BRIDGE.  It then uses that bridge, using standard
PCI mechanisms, to set everything up in the slow-path.


>  Negotiate hypercall support
> (e.g.  with a PCI capability) and then switch to that for fastpath. Hmm=
?
>=20
>> As another example, the connector design coalesces *all* shm-signals
>> into a single interrupt (by prio) that uses the same context-switch
>> mitigation techniques that help boost things like networking.  This
>> effectively means we can detect and optimize out ack/eoi cycles from t=
he
>> APIC as the IO load increases (which is when you need it most).  PCI h=
as
>> no such concept.
>=20
> Could you elaborate on this one for me? How does context-switch
> mitigation work?

What I did was I commoditized the concept of signal-mitigation.  I then
reuse that concept all over the place to do "NAPI" like mitigation of
the signal path for everthing: for individual interrupts, of course, but
also for things like hypercalls, kthread wakeups, and the interrupt
controller too.


>=20
>> In addition, the signals and interrupts are priority aware, which is
>> useful for things like 802.1p networking where you may establish 8-tx
>> and 8-rx queues for your virtio-net device.  x86 APIC really has no
>> usable equivalent, so PCI is stuck here.
>=20
> By the way, multiqueue support in virtio would be very nice to have,

Actually what I am talking about is a little different than MQ, but I
agree that both priority-based and concurrency-based MQ would require
similar facilities.

> and seems mostly unrelated to vbus.

Mostly, but not totally.  The priority stuff wouldn't work quite right
without similar provisions to the entire signal path, like vbus does.

Kind Regards,
-Greg






--------------enig61D0CCB6CF544BBB82BE2776
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqKyy0ACgkQP5K2CMvXmqEe9gCfQRuQsA3gDcVF9iCHL2kw3+L8
dsEAn1GuhrZiOG5QlS95rgl8hy2JOPSn
=QGGt
-----END PGP SIGNATURE-----

--------------enig61D0CCB6CF544BBB82BE2776--
