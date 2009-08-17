From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 11:05:12 -0400
Message-ID: <4A8971A8.2040102@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig29A378C2736ADAC434254256"
Cc: Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090817142506.GB3602@elte.hu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig29A378C2736ADAC434254256
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Ingo Molnar wrote:
> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
>=20
>> Ingo Molnar wrote:
>>> * Gregory Haskins <ghaskins@novell.com> wrote:
>>>
>>>> This will generally be used for hypervisors to publish any host-side=

>>>> virtual devices up to a guest.  The guest will have the opportunity
>>>> to consume any devices present on the vbus-proxy as if they were
>>>> platform devices, similar to existing buses like PCI.
>>>>
>>>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
>>>> ---
>>>>
>>>>  MAINTAINERS                 |    6 ++
>>>>  arch/x86/Kconfig            |    2 +
>>>>  drivers/Makefile            |    1=20
>>>>  drivers/vbus/Kconfig        |   14 ++++
>>>>  drivers/vbus/Makefile       |    3 +
>>>>  drivers/vbus/bus-proxy.c    |  152 ++++++++++++++++++++++++++++++++=
+++++++++++
>>>>  include/linux/vbus_driver.h |   73 +++++++++++++++++++++
>>>>  7 files changed, 251 insertions(+), 0 deletions(-)
>>>>  create mode 100644 drivers/vbus/Kconfig
>>>>  create mode 100644 drivers/vbus/Makefile
>>>>  create mode 100644 drivers/vbus/bus-proxy.c
>>>>  create mode 100644 include/linux/vbus_driver.h
>>> Is there a consensus on this with the KVM folks? (i've added the KVM =

>>> list to the Cc:)
>>>
>>>
>> Hi Ingo,
>>
>> Avi can correct me if I am wrong, but the agreement that he and I=20
>> came to a few months ago was something to the effect of:
>>
>> kvm will be neutral towards various external IO subsystems, and=20
>> instead provide various hooks (see irqfd, ioeventfd) to permit=20
>> these IO subsystems to interface with kvm.
>>
>> AlacrityVM is one of the first projects to take advantage of that=20
>> interface.  AlacrityVM is kvm-core + vbus-core +=20
>> vbus-kvm-connector + vbus-enhanced qemu + guest drivers.  This=20
>> thread is part of the guest-drivers portion.  Note that it is=20
>> specific to alacrityvm, not kvm, which is why the kvm list was not=20
>> included in the conversation (also an agreement with Avi:=20
>> http://lkml.org/lkml/2009/8/6/231).
>=20
> Well my own opinion is that the fracturing of the Linux internal=20
> driver space into diverging pieces of duplicate functionality=20
> (absent compelling technical reasons) is harmful.

[Adding Michael Tsirkin]

Hi Ingo,

1) First off, let me state that I have made every effort to propose this
as a solution to integrate with KVM, the most recent of which is April:

http://lkml.org/lkml/2009/4/21/408

If you read through the various vbus related threads on LKML/KVM posted
this year, I think you will see that I made numerous polite offerings to
work with people on finding a common solution here, including Michael.

In the end, Michael decided that go a different route using some of the
ideas proposed in vbus + venet-tap to create vhost-net.  This is fine,
and I respect his decision.  But do not try to pin "fracturing" on me,
because I tried everything to avoid it. :)

Since I still disagree with the fundamental approach of how KVM IO
works, I am continuing my effort in the downstream project "AlacrityVM"
which will hopefully serve to build a better understanding of what it is
I am doing with the vbus technology, and a point to maintain the subsyste=
m.

2) There *are* technical reasons for this change (and IMHO, they are
compelling), many of which have already been previously discussed
(including my last reply to Anthony) so I wont rehash them here.

3) Even if there really is some duplication here, I disagree with you
that it is somehow harmful to the Linux community per se.  Case in
point, look at the graphs posted on the AlacrityVM wiki:

http://developer.novell.com/wiki/index.php/AlacrityVM

Prior to my effort, KVM was humming along at the status quo and I came
along with a closer eye and almost doubled the throughput and cut
latency by 78%.  Given an apparent disagreement with aspects of my
approach, Michael went off and created a counter example that was
motivated by my performance findings.

Therefore, even if Avi ultimately accepts Michaels vhost approach
instead of mine, Linux as a hypervisor platform has been significantly
_improved_ by a little friendly competition, not somehow damaged by it.

4) Lastly, these patches are almost entirely just stand alone Linux
drivers that do not affect KVM if KVM doesn't wish to acknowledge them.
 Its just like any of the other numerous drivers that are accepted
upstream into Linux every day.  The only maintained subsystem that is
technically touched by this series is netdev, and David Miller already
approved of the relevant patch's inclusion:

http://lkml.org/lkml/2009/8/3/505

So with all due respect, where is the problem?  The patches are all
professionally developed according to the Linux coding standards, pass
checkpatch, are GPL'ed, and work with a freely available platform which
you can download today
(http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.=
6.git;a=3Dsummary)


Kind Regards,
-Greg





--------------enig29A378C2736ADAC434254256
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqJcagACgkQP5K2CMvXmqETlACfaRqXAWV1Swffs0Gb8JvKK8kR
j7oAn0WNeFRouEia1QjT/V9wA2i8euRM
=ikyA
-----END PGP SIGNATURE-----

--------------enig29A378C2736ADAC434254256--
