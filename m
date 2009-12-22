From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 12:36:52 -0500
Message-ID: <4B3103B4.4070708@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8551EF63152946F7DFEB1E80"
Cc: Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754372AbZLVRhN@vger.kernel.org>
In-Reply-To: <20091222075742.GB26467@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8551EF63152946F7DFEB1E80
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/22/09 2:57 AM, Ingo Molnar wrote:
>=20
> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
>=20
>> On 12/18/09 4:51 PM, Ingo Molnar wrote:
>>>
>>> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
>>>
>>>> Hi Linus,
>>>>
>>>> Please pull AlacrityVM guest support for 2.6.33 from:
>>>>
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/li=
nux-2.6.git
>>>> for-linus
>>>>
>>>> All of these patches have stewed in linux-next for quite a while now=
:
>>>>
>>>> Gregory Haskins (26):
>>>
>>> I think it would be fair to point out that these patches have been ob=
jected to=20
>>> by the KVM folks quite extensively,
>>
>> Actually, these patches have nothing to do with the KVM folks. [...]
>=20
> That claim is curious to me - the AlacrityVM host

It's quite simple, really.  These drivers support accessing vbus, and
vbus is hypervisor agnostic.  In fact, vbus isn't necessarily even
hypervisor related.  It may be used anywhere where a Linux kernel is the
"io backend", which includes hypervisors like AlacrityVM, but also
userspace apps, and interconnected physical systems as well.

The vbus-core on the backend, and the drivers on the frontend operate
completely independent of the underlying hypervisor.  A glue piece
called a "connector" ties them together, and any "hypervisor" specific
details are encapsulated in the connector module.  In this case, the
connector surfaces to the guest side as a pci-bridge, so even that is
not hypervisor specific per se.  It will work with any pci-bridge that
exposes a compatible ABI, which conceivably could be actual hardware.

The AlacrityVM project just so happens to be the primary consumer, and
is therefore the most convenient way to package them up at the moment.

> is 90% based on KVM code, so=20
> how can it not be about KVM? I just checked, most of the changes that=20
> AlacrityVM host does to KVM is in adding the host side interfaces for t=
hese=20
> guest drivers:
>=20
>  virt/kvm/Kconfig          |   11 +
>  virt/kvm/coalesced_mmio.c |   65 +++---
>  virt/kvm/coalesced_mmio.h |    1 +
>  virt/kvm/eventfd.c        |  599 +++++++++++++++++++++++++++++++++++++=
++++++++
>  virt/kvm/ioapic.c         |  118 +++++++--
>  virt/kvm/ioapic.h         |    5 +
>  virt/kvm/iodev.h          |   55 +++--
>  virt/kvm/irq_comm.c       |  267 ++++++++++++++-------
>  virt/kvm/kvm_main.c       |  127 ++++++++--
>  virt/kvm/xinterface.c     |  587 +++++++++++++++++++++++++++++++++++++=
+++++++
>  10 files changed, 1649 insertions(+), 186 deletions(-)
>=20
>  [ stat for virt/kvm/ taken as of today, AlacrityVM host tree commit 84=
afcc7 ]
>=20
> So as far as kernel code modifications of AlacrityVM goes, it's very mu=
ch=20
> about KVM.

I think you are confused.  Even if we entertained the notion that the
host side diffstat were somehow relevant here, you are probably
comparing the kvm.git backports that are in my tree.  The only real KVM
specific change that is in my tree is the 587 lines for the xinterface.c
module, which is about ~4%, not 90%.  Also note that I have pushed this
xinterface logic upstream already, but it just hasn't been accepted yet.

If I wanted to be extremely generous, you could include the entire "KVM
connector" code that bridges vbus-core to kvm-core, but even that tops
out at a total of ~17% of the changes in my tree.  So I am still not
seeing the 90% nor how it is relevant.

>=20
>> [...]  You are perhaps confusing this with the hypervisor-side discuss=
ion,=20
>> of which there is indeed much disagreement.
>=20
> Are the guest drivers living in a vacuum? The whole purpose of the Alac=
rityVM=20
> guest drivers is to ... enable AlacrityVM support, right?

More specifically, the purpose of the drivers, like any driver, is to
enable support for the underlying device in which it is related to.  In
this case, the devices are vbus based devices.  Of those, AlacrityVM is
the only available platform that exposes them.  However, that is a
maturity/adoption detail, not a technical limitation.  Simply
implementing a new connector would bridge these drivers to other
environments as well.  There are community members working on these as
we speak, as a matter of fact.

> So how can it be not about KVM?

Because AlacrityVM is a hypervisor that supports VBUS for PV IO, and KVM
is not.  In addition, the presence of these drivers in no way alters,
interferes with, or diminishes features found in KVM today.  So it is,
and never will be about KVM until upstream KVM decides that they want to
support VBUS based PV-IO.

If you want to talk about the host side, then I have +587 lines that
hang in the balance that affect KVM, yes.  But that isn't what $subject
was about.

>=20
> Gregory, it would be nice if you worked _much_ harder with the KVM folk=
s=20
> before giving up.

I think the 5+ months that I politely tried to convince the KVM folks
that this was a good idea was pretty generous of my employer.  The KVM
maintainers have ultimately made it clear they are not interested in
directly supporting this concept (which is their prerogative), but are
perhaps willing to support the peripheral logic needed to allow it to
easily interface with KVM.  I can accept that, and thus AlacrityVM was bo=
rn.

Note that upstream KVM are also only a subset of the mindshare needed
for this project anyway, since most of the core is independent of KVM.
Perhaps the KVM folks will reconsider if/when other community members
start to see the merit in the work.  Perhaps not.  It's out of my
control at this point.

> It's not like there's much valid technical disagreement that=20
> i can identify in any of the threads

While I am sorry to hear that, it should be noted that this doesn't mean
that your perception is accurate, either.  It was quite a long and
fragmented set of threads over those 5+ months, so absorbing the gist of
the vision from casual observation is not likely trivial.

> - the strongest one i could identify was:=20
> "I want to fork KVM so please let me do it, nobody is harmed, choice is=
 good".

Everyone is of course entitled to an opinion, but I would respectfully
disagree with your statement (as I did last time you made the same
claim, as well).  I have now, nor ever, wanted a fork.  But I also
believe in the work I am doing, so I won't roll over and die just
because a certain group doesn't share the vision per se either, sorry.
I get the impression that you would not either if you were in a similar
situation, so perhaps you can respect that.

Kind Regards,
-Greg


--------------enig8551EF63152946F7DFEB1E80
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksxA7QACgkQP5K2CMvXmqE31gCfQ1O8MYtLDN73ydXStDDawlj/
KTYAn1azIOCX8UJB7vw4qZCpbxAcWsIt
=eh30
-----END PGP SIGNATURE-----

--------------enig8551EF63152946F7DFEB1E80--
