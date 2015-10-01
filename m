From: Al Stone <ahs3@redhat.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Wed, 30 Sep 2015 20:23:57 -0600
Message-ID: <560C993D.8090308@redhat.com>
References: <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
 <1443033714.74600.18.camel@infradead.org> <560310EA.2070805@intel.com>
 <1443042212.74600.30.camel@infradead.org> <56033C10.2040708@linaro.org>
 <1443082579.74600.48.camel@infradead.org>
 <20150924103152.GG13823@e104818-lin.cambridge.arm.com>
 <1443095558.74600.84.camel@infradead.org>
 <20150924151546.GJ13823@e104818-lin.cambridge.arm.com>
 <1443118238.74600.117.camel@infradead.org>
 <20150925152848.GQ13823@e104818-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <jeremy.linton@arm.com>,
	Hanjun Guo <hanjun.guo@linaro.org>,
	Suravee.Suthikulpanit@amd.com, grant.likely@linaro.org,
	linux-arm-kernel@lists.infradead.org,
	Charles Garcia-Tobin <Charles.Garcia-Tobin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbbJACYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 22:24:00 -0400
In-Reply-To: <20150925152848.GQ13823@e104818-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding Charles Garcia-Tobin from ARM....

On 09/25/2015 09:28 AM, Catalin Marinas wrote:
> On Thu, Sep 24, 2015 at 07:10:38PM +0100, David Woodhouse wrote:
>> On Thu, 2015-09-24 at 16:15 +0100, Catalin Marinas wrote:
>>> With "PRP0001", they can skip the _DSD properties review process (n=
ot
>>> that they bother much currently) as long as the existing DT support
>>> covers their needs.
>>
>> So no change there then. I take it the smsc911x bindings didn't go
>> through this mythical _DSD properties review process either, right?
>=20
> Right. And that's another reason I disagree with this patchset (I don=
't
> always agree with everything that's coming out of ARM Ltd ;)).
>=20
> Now, in Jeremy's defence, this _DSD process looks quite mythical inde=
ed.
> We had an ARM firmware ecosystem meeting earlier this year where we
> agreed to set up such process (at least for the ARM world):
>=20
> https://wiki.linaro.org/LEG/Engineering/Kernel/ACPI/CoreUpstreamNotes
>=20
> I can see some form of a process here:
>=20
> http://www.uefi.org/sites/default/files/resources/web-page-v2.pdf
>=20
> But, at least to me, it's not clear how you submit properties to such
> registry, what's the review process, who are the reviewers. I know th=
ere
> was a mailing list set up but I don't see it listed above.

To repeat Rafael a bit, getting the process set up -- moving it from th=
e
mythical to the practical -- is taking longer than expected.  Some folk=
s
that had agreed to do so made no progress at all for many months, but I
was way too polite and waited for something to happen.

So, it turns out I'm impatient at times.  This _DSD stuff is bugging me=
 and
the itch needs scratching.  And, it absolutely affects ACPI on ARM serv=
ers
so it has my interest.  I have thrown out some basic proposals, and in
conjunction with the ASWG (ACPI Spec Working Group of UEFI), Rafael, an=
d
Charles, we're trying to get some things decided and moving.

Here is where I think we are:

   -- We have defined a very clear boundary between ASWG and the defini=
tion
      of _DSD device properties.  The bottom line is that all device pr=
operty
      definition is outside the scope of the ASWG; the ASWG has defined=
 the
      structure they must take in ASL, but the actual content of any _D=
SD
      we can discuss and define in public forums without having to conc=
ern
      ourselves about the spec in any way.  This was an essential step =
in
      order to make IP rules clear.

   -- There is a mailing list set up (dsd@acpica.org), originally set u=
p as
      the starting point for a review process.  I have recently started=
 up
      some discussion there on what needs to be submitted.  I will soon=
 be
      posting updates to the discussion to lay out proposed review proc=
esses
      and the proposed formalisms to be used in describing device prope=
rties
      for review.  Please subscribe and read the archives (not very lar=
ge)
      that can be found here: https://lists.acpica.org/mailman/listinfo=
/dsd

      In the meantime, device property definition review can start occu=
rring
      on the dsd@acpica.org list with the caveat that process is still =
being
      defined.  At least if things are put in the email archive, we've =
got a
      starting point.

   -- Unfortunately, the material currently on the UEFI site about _DSD=
 (other
      than its definition) should be ignored -- it reflects much earlie=
r views
      and was incomplete to begin with.  I wrote what's there and have =
no qualms
      in saying it is now inadequate.  This is being corrected but it n=
eeds to
      go through ASWG to be fixed.

   -- An initial draft of a proposal for a metalanguage for describing =
and
      storing device properties has been under review.  I'm working out=
 v2 of
      this formalism.  This will allow us to document the device proper=
ties in
      a reliable way, and build a repository of the definitions that is=
 easily
      shared.

   -- What documentation/proposals we do have I have stashed in github.=
  Please
      see https://github.com/ahs3/dsd/tree/v-next/ for the work in prog=
ress.

What needs to happen next?

   -- First, finalize the review process (discussion on dsd@apcica.org)=
=2E

   -- Second, finalize the reviewers (discussion on dsd@).

   -- Third, but in parallel, finalize formalisms for describing device
      properties and build the tools needs to validate them, store them=
,
      maintain them, and store them for public consumption (discussion
      also on dsd@).

   -- Make a couple of decisions (see below...)

>>>  However, we don't want to emulate DT in ACPI but > first try the
>>> established ACPI methods and only use _DSD where these are
>>> insufficient. Automatically converting existing drivers and encoura=
ging
>>> people to use "PRP0001" does not provide them with any incentive to=
 try
>>> harder and learn the "ACPI way".
>>
>> But again, we're *not* looking at a simplistic transliteration of
>> properties.
>=20
> I know you and I don't look at it this way but, based on historical
> evidence, I'm sure that some ARM vendors will try to do exactly this
> (and be able to claim "ACPI support" when they were happily using DT)=
=2E

Based on the discussion so far, I think everyone is agreeing that we
do NOT want to just blindly reproduce DT using _DSD properties.  Is tha=
t
a fair statement?

>>>> In some ways, your proposal would be actively *counterproductive*.=
 You
>>>> say you want to train people *not* to keep patching the kernel. Bu=
t
>>>> where they *could* have just used PRP0001 and used a pre-existing
>>>> kernel, you then tell them "oh, but now you need to patch the kern=
el
>>>> because we want you to make up a new HID and not be compatible wit=
h
>>>> what already exists."
>>>
>>> I gave an example above with the clocks but let's take a simpler,
>>> device-specific property like "smsc,irq-active-high". Is this docum=
ented
>>> anywhere apart from the kernel driver and the in-kernel DT smsc911x=
=2Etxt?
>>> No. Are other non-Linux OS vendors going to look in the kernel sour=
ce
>>> tree to implement support in their drivers? I doubt it and we could=
 end
>>> up with two different paths in firmware for handling the same devic=
e.
>>> ACPI probably never was truly OS agnostic but with "PRP0001" we don=
't
>>> even try.
>>
>> Where is the documentation for the INT_CFG_IRQ_POL_ bit in the INT_C=
=46G
>> register, that it controls? The documentation on the bindings really
>> ought to live near that, in an ideal world.
>=20
> If not there, at least in some common place like this:
>=20
> http://www.uefi.org/sites/default/files/resources/nic-request-v2.pdf
>=20
> And they could be specific to a newly allocated HID (like we do with =
DT
> for a newly allocated "compatible" string).

A common location has some other rules, too: (1) people from Microsoft
or other OS vendors (e.g., BSDs) need to be able to easily access it,
and (2) firmware developers needs to be able to easily find it and use
it.  My thinking today is that I can (and will) set up a repository in
the github I'm using that will contain a human readable formal descript=
ion
of all the approved device properties.  Further (thanks to Mark Brown f=
or
the idea), there needs to be a second repository co-located with the fi=
rst
that contains device properties discovered in the wild but never "appro=
ved."
I'll even offer to maintain these repositories for the time being, unti=
l
we as a community decide on something better.

>> But that's still a non-sequitur in the context of this particular
>> discussion. The patch that was posted *already* keeps that very same
>> (optional) smsc,irq-active-high property.=20
>>
>> Again, it isn't relevant to the question of whether the driver is
>> matched via PRP0001 or a newly-allocated HID.
>>
>> The driver, as the patch was posted, *does* have the same set of
>> properties with the same meanings =E2=80=94 because anything else wo=
uld be
>> insane.
>=20
> Having the same set of properties makes sense. But not documenting th=
em
> outside of Documentation/devicetree/bindings/ doesn't look right to m=
e,
> from an OS-agnostic ACPI perspective.
>=20
> Let's take it the other way. A new driver is being submitted to Linux
> (or another OS) with support for ACPI (only). The developers may find=
 it
> easier to use PRP0001 with their own _DSD invention. Do we ask the
> developers to submit DT bindings even if they don't immediately targe=
t
> DT (even harder if Linux is not the first target)? Or we skip this
> properties review and documenting process altogether? At least with D=
T,
> we usually see the bindings and kernel code together and have a chanc=
e
> to NAK. For _DSD we need something outside the Linux kernel community=
=2E
>=20
> But I agree with your statement above, it's not relevant whether a ne=
w
> _HID is used or PRP0001 + "compatible" when we don't even control whi=
ch
> _DSD properties are added.
>=20
> As I said previously, disabling PRP0001 on ARM is more of a weak meth=
od
> of keeping track of which drivers are used with ACPI. My concern (and=
 it
> won't go away) is a thoughtless migration of existing DT drivers and =
ARM
> SoCs to ACPI. PRP0001 makes it easier though it's _DSD actually
> facilitating this.

I have to agree with Catalin here.  I was on the ASWG when _DSD was pro=
posed,
and when PRP0001 was proposed and they seemed reasonable at the time.  =
However,
the more I think about PRP0001, the more I think I dislike it.  It allo=
ws for
short-circuiting any sort of review about device properties in the driv=
ers,
regardless of whether they support DT or ACPI or both -- and people wil=
l choose
the path of least resistance given any choice at all.

>>> Apart from a _DSD properties review process, what we need is (main)=
 OS
>>> vendors enforcing it, possibly with stricter ACPI test suite. Disab=
ling
>>> PRP0001 for ARM wouldn't solve the problem but at least it would ma=
ke
>>> people think about what _DSD properties they need registered for th=
eir
>>> device (or I'm over optimistic and I should just stop caring ;)).

It's not foolproof, but if we disallow PRP0001 we might be able to enco=
urage
some sort of review to occur before code gets dropped into the kernel w=
here
it will need to be maintained forever.

So, here's another decision point: do we disallow the use of PRP0001 fo=
r device
properties on ARMv8 servers using ACPI?  And should other architectures=
 be able
to do as they wish with PRP0001?  The previous discussion seems to say =
"yes" to
both questions, correct?

>>
>> I'm all for requiring pre-existing DT bindings to be "vetted" by the
>> nascent _DSD review process, before their use with PRP0001 can be
>> 'blessed'.
>=20
> If we want something enforced here, we need a better methodology than
> keeping track of which patches are submitted (and this would involve =
OS
> vendors support since in many cases their kernels are seen as the
> "canonical" implementation).

Agreed.  This is what Charles, Rafael and I have started discussing on =
the
dsd@acpica.org mailing list.  I have proposed a formalism for describin=
g
properties (actively being revised) and we have some basic process prop=
osals
being discussed.  More voices are needed; we're just starting to get th=
ings
moving after they've been in stasis so long.

While I cannot speak for Red Hat as a whole, for myself I really want f=
or there
to be a single place I can go to where I can find out which device prop=
erties
are actually defined, which are not, and to be able to point to when so=
me random
bit of hardware or firmware decides to do something completely differen=
t and
breaks my OS.  Help Charles, Rafael and I define the vetting process an=
d the
things to be vetted and I think we can have a decent methodology in pla=
ce.

>> But in a world where people *are* going to go off and do their own
>> insane thing, we really might as well let them use the *same* thing
>> that we already had =E2=80=94 in as many cases as possible =E2=80=94=
 rather than
>> actually *making* them come up with a new insane thing all of their
>> very own.
>=20
> This only works as long as they target an existing driver with prior =
DT
> support (usually with reviewed bindings). If they have a new driver a=
nd
> only ACPI in mind, I'm pretty sure we'll end up with new insane thing=
s.
> That's why we need some form of _DSD properties review and "compatibl=
e"
> is one such property.
>=20

Again, based on the emails so far, it seems everyone is agreeing that w=
e
need a review process, and that we need to make sure we don't accept an=
ything
into the kernel that has not been reviewed; it won't fix everything, bu=
t it
at least gives us a fighting chance.  Any disagreement with that?

--=20
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Red Hat, Inc.
ahs3@redhat.com
-----------------------------------
