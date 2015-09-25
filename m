From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Fri, 25 Sep 2015 16:28:49 +0100
Message-ID: <20150925152848.GQ13823@e104818-lin.cambridge.arm.com>
References: <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
 <1443033714.74600.18.camel@infradead.org>
 <560310EA.2070805@intel.com>
 <1443042212.74600.30.camel@infradead.org>
 <56033C10.2040708@linaro.org>
 <1443082579.74600.48.camel@infradead.org>
 <20150924103152.GG13823@e104818-lin.cambridge.arm.com>
 <1443095558.74600.84.camel@infradead.org>
 <20150924151546.GJ13823@e104818-lin.cambridge.arm.com>
 <1443118238.74600.117.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <jeremy.linton@arm.com>,
	Hanjun Guo <hanjun.guo@linaro.org>,
	Suravee.Suthikulpanit@amd.com, grant.likely@linaro.org,
	linux-arm-kernel@lists.infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:42473 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932380AbbIYP2x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 11:28:53 -0400
Content-Disposition: inline
In-Reply-To: <1443118238.74600.117.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 07:10:38PM +0100, David Woodhouse wrote:
> On Thu, 2015-09-24 at 16:15 +0100, Catalin Marinas wrote:
> > With "PRP0001", they can skip the _DSD properties review process (n=
ot
> > that they bother much currently) as long as the existing DT support
> > covers their needs.
>=20
> So no change there then. I take it the smsc911x bindings didn't go
> through this mythical _DSD properties review process either, right?

Right. And that's another reason I disagree with this patchset (I don't
always agree with everything that's coming out of ARM Ltd ;)).

Now, in Jeremy's defence, this _DSD process looks quite mythical indeed=
=2E
We had an ARM firmware ecosystem meeting earlier this year where we
agreed to set up such process (at least for the ARM world):

https://wiki.linaro.org/LEG/Engineering/Kernel/ACPI/CoreUpstreamNotes

I can see some form of a process here:

http://www.uefi.org/sites/default/files/resources/web-page-v2.pdf

But, at least to me, it's not clear how you submit properties to such
registry, what's the review process, who are the reviewers. I know ther=
e
was a mailing list set up but I don't see it listed above.

> >  However, we don't want to emulate DT in ACPI but > first try the
> > established ACPI methods and only use _DSD where these are
> > insufficient. Automatically converting existing drivers and encoura=
ging
> > people to use "PRP0001" does not provide them with any incentive to=
 try
> > harder and learn the "ACPI way".
>=20
> But again, we're *not* looking at a simplistic transliteration of
> properties.

I know you and I don't look at it this way but, based on historical
evidence, I'm sure that some ARM vendors will try to do exactly this
(and be able to claim "ACPI support" when they were happily using DT).

> > > In some ways, your proposal would be actively *counterproductive*=
=2E You
> > > say you want to train people *not* to keep patching the kernel. B=
ut
> > > where they *could* have just used PRP0001 and used a pre-existing
> > > kernel, you then tell them "oh, but now you need to patch the ker=
nel
> > > because we want you to make up a new HID and not be compatible wi=
th
> > > what already exists."
> >=20
> > I gave an example above with the clocks but let's take a simpler,
> > device-specific property like "smsc,irq-active-high". Is this docum=
ented
> > anywhere apart from the kernel driver and the in-kernel DT smsc911x=
=2Etxt?
> > No. Are other non-Linux OS vendors going to look in the kernel sour=
ce
> > tree to implement support in their drivers? I doubt it and we could=
 end
> > up with two different paths in firmware for handling the same devic=
e.
> > ACPI probably never was truly OS agnostic but with "PRP0001" we don=
't
> > even try.
>=20
> Where is the documentation for the INT_CFG_IRQ_POL_ bit in the INT_CF=
G
> register, that it controls? The documentation on the bindings really
> ought to live near that, in an ideal world.

If not there, at least in some common place like this:

http://www.uefi.org/sites/default/files/resources/nic-request-v2.pdf

And they could be specific to a newly allocated HID (like we do with DT
for a newly allocated "compatible" string).

> But that's still a non-sequitur in the context of this particular
> discussion. The patch that was posted *already* keeps that very same
> (optional) smsc,irq-active-high property.=20
>=20
> Again, it isn't relevant to the question of whether the driver is
> matched via PRP0001 or a newly-allocated HID.
>=20
> The driver, as the patch was posted, *does* have the same set of
> properties with the same meanings =E2=80=94 because anything else wou=
ld be
> insane.

Having the same set of properties makes sense. But not documenting them
outside of Documentation/devicetree/bindings/ doesn't look right to me,
from an OS-agnostic ACPI perspective.

Let's take it the other way. A new driver is being submitted to Linux
(or another OS) with support for ACPI (only). The developers may find i=
t
easier to use PRP0001 with their own _DSD invention. Do we ask the
developers to submit DT bindings even if they don't immediately target
DT (even harder if Linux is not the first target)? Or we skip this
properties review and documenting process altogether? At least with DT,
we usually see the bindings and kernel code together and have a chance
to NAK. For _DSD we need something outside the Linux kernel community.

But I agree with your statement above, it's not relevant whether a new
_HID is used or PRP0001 + "compatible" when we don't even control which
_DSD properties are added.

As I said previously, disabling PRP0001 on ARM is more of a weak method
of keeping track of which drivers are used with ACPI. My concern (and i=
t
won't go away) is a thoughtless migration of existing DT drivers and AR=
M
SoCs to ACPI. PRP0001 makes it easier though it's _DSD actually
facilitating this.

> > Apart from a _DSD properties review process, what we need is (main)=
 OS
> > vendors enforcing it, possibly with stricter ACPI test suite. Disab=
ling
> > PRP0001 for ARM wouldn't solve the problem but at least it would ma=
ke
> > people think about what _DSD properties they need registered for th=
eir
> > device (or I'm over optimistic and I should just stop caring ;)).
>=20
> I'm all for requiring pre-existing DT bindings to be "vetted" by the
> nascent _DSD review process, before their use with PRP0001 can be
> 'blessed'.

If we want something enforced here, we need a better methodology than
keeping track of which patches are submitted (and this would involve OS
vendors support since in many cases their kernels are seen as the
"canonical" implementation).

> But in a world where people *are* going to go off and do their own
> insane thing, we really might as well let them use the *same* thing
> that we already had =E2=80=94 in as many cases as possible =E2=80=94 =
rather than
> actually *making* them come up with a new insane thing all of their
> very own.

This only works as long as they target an existing driver with prior DT
support (usually with reviewed bindings). If they have a new driver and
only ACPI in mind, I'm pretty sure we'll end up with new insane things.
That's why we need some form of _DSD properties review and "compatible"
is one such property.

--=20
Catalin
