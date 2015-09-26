From: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Sat, 26 Sep 2015 04:16:31 +0200
Message-ID: <5605FFFF.2010307@intel.com>
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
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Woodhouse <dwmw2@infradead.org>,
	steve.glendinning@shawell.net, netdev@vger.kernel.org,
	Jeremy Linton <jeremy.linton@arm.com>,
	Hanjun Guo <hanjun.guo@linaro.org>,
	Suravee.Suthikulpanit@amd.com, grant.likely@linaro.org,
	linux-arm-kernel@lists.infradead.org, rafael@kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:20807 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755180AbbIZCQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 22:16:36 -0400
In-Reply-To: <20150925152848.GQ13823@e104818-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/25/2015 5:28 PM, Catalin Marinas wrote:
> On Thu, Sep 24, 2015 at 07:10:38PM +0100, David Woodhouse wrote:
>> On Thu, 2015-09-24 at 16:15 +0100, Catalin Marinas wrote:
>>> With "PRP0001", they can skip the _DSD properties review process (n=
ot
>>> that they bother much currently) as long as the existing DT support
>>> covers their needs.
>> So no change there then. I take it the smsc911x bindings didn't go
>> through this mythical _DSD properties review process either, right?
> Right. And that's another reason I disagree with this patchset (I don=
't
> always agree with everything that's coming out of ARM Ltd ;)).
>
> Now, in Jeremy's defence, this _DSD process looks quite mythical inde=
ed.
> We had an ARM firmware ecosystem meeting earlier this year where we
> agreed to set up such process (at least for the ARM world):
>
> https://wiki.linaro.org/LEG/Engineering/Kernel/ACPI/CoreUpstreamNotes
>
> I can see some form of a process here:
>
> http://www.uefi.org/sites/default/files/resources/web-page-v2.pdf

That was just an attempt and the final one will most likely be differen=
t.

> But, at least to me, it's not clear how you submit properties to such
> registry, what's the review process, who are the reviewers. I know th=
ere
> was a mailing list set up but I don't see it listed above.

=46or the record, this is under discussion right now.

Also for the record, I'm not speaking for Intel.  All of my comments=20
here are based on my personal opinions.

>>>   However, we don't want to emulate DT in ACPI but > first try the
>>> established ACPI methods and only use _DSD where these are
>>> insufficient. Automatically converting existing drivers and encoura=
ging
>>> people to use "PRP0001" does not provide them with any incentive to=
 try
>>> harder and learn the "ACPI way".
>> But again, we're *not* looking at a simplistic transliteration of
>> properties.
> I know you and I don't look at it this way but, based on historical
> evidence, I'm sure that some ARM vendors will try to do exactly this
> (and be able to claim "ACPI support" when they were happily using DT)=
=2E
>
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
>> Where is the documentation for the INT_CFG_IRQ_POL_ bit in the INT_C=
=46G
>> register, that it controls? The documentation on the bindings really
>> ought to live near that, in an ideal world.
> If not there, at least in some common place like this:
>
> http://www.uefi.org/sites/default/files/resources/nic-request-v2.pdf
>
> And they could be specific to a newly allocated HID (like we do with =
DT
> for a newly allocated "compatible" string).
>
>> But that's still a non-sequitur in the context of this particular
>> discussion. The patch that was posted *already* keeps that very same
>> (optional) smsc,irq-active-high property.
>>
>> Again, it isn't relevant to the question of whether the driver is
>> matched via PRP0001 or a newly-allocated HID.
>>
>> The driver, as the patch was posted, *does* have the same set of
>> properties with the same meanings =E2=80=94 because anything else wo=
uld be
>> insane.
> Having the same set of properties makes sense. But not documenting th=
em
> outside of Documentation/devicetree/bindings/ doesn't look right to m=
e,
> from an OS-agnostic ACPI perspective.

They are documented in the code too through the requirements that the=20
existing drivers have.

If I have a piece of hardware and a driver for it, it really shouldn't=20
matter whether I use a DT or ACPI in my platform.  The driver should=20
just work in both cases.  It doesn't have to work in exactly the same=20
way, but it should work.  That's not the case today, sadly.

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
>
> But I agree with your statement above, it's not relevant whether a ne=
w
> _HID is used or PRP0001 + "compatible" when we don't even control whi=
ch
> _DSD properties are added.
>
> As I said previously, disabling PRP0001 on ARM is more of a weak meth=
od
> of keeping track of which drivers are used with ACPI. My concern (and=
 it
> won't go away) is a thoughtless migration of existing DT drivers and =
ARM
> SoCs to ACPI. PRP0001 makes it easier though it's _DSD actually
> facilitating this.

Even if they tried to do that, infrastructure is missing for things lik=
e=20
regulators etc (because the frameworks there use of_ helpers directly=20
IIRC and I'm not aware of any plans to change that) and on the other=20
hand GPIO already depends on _CRS being used in accordance with ACPI=20
anyway (even if _DSD properties are used), so I'd say this would be=20
practically difficult rather.

IOW, using _DSD properties for individual devices/drivers is easy. Doin=
g=20
the same thing for the whole system, not so much.

>>> Apart from a _DSD properties review process, what we need is (main)=
 OS
>>> vendors enforcing it, possibly with stricter ACPI test suite. Disab=
ling
>>> PRP0001 for ARM wouldn't solve the problem but at least it would ma=
ke
>>> people think about what _DSD properties they need registered for th=
eir
>>> device (or I'm over optimistic and I should just stop caring ;)).
>> I'm all for requiring pre-existing DT bindings to be "vetted" by the
>> nascent _DSD review process, before their use with PRP0001 can be
>> 'blessed'.
> If we want something enforced here, we need a better methodology than
> keeping track of which patches are submitted (and this would involve =
OS
> vendors support since in many cases their kernels are seen as the
> "canonical" implementation).
>
>> But in a world where people *are* going to go off and do their own
>> insane thing, we really might as well let them use the *same* thing
>> that we already had =E2=80=94 in as many cases as possible =E2=80=94=
 rather than
>> actually *making* them come up with a new insane thing all of their
>> very own.
> This only works as long as they target an existing driver with prior =
DT
> support (usually with reviewed bindings).

Exactly.

And this is what we (David and me at least) want to be possible.  It=20
would be a failure if people had to write separate drivers for=20
ACPI-based and DT-based platforms to handle the same hardware, at least=
=20
at the leaf driver level.

> If they have a new driver and
> only ACPI in mind, I'm pretty sure we'll end up with new insane thing=
s.

We will.  With or without _DSD and all.  That had happened way before=20
_DSD was introduced.

And by the way, demonizing _DSD doesn't help you at all, because there=20
was the *much* *worse* thing called _DSM way before and it allowed of=20
the same things as _DSD does and more.  And it still is there and it=20
very well may be used to feed an entire DT in binary format to the=20
kernel when no one is looking.

So this is all about tradeoffs.  If you don't give people enough rope t=
o=20
do something, they'll find another way and you may hate that one, but=20
then it'll be too late.

> That's why we need some form of _DSD properties review and "compatibl=
e"
> is one such property.
>

Yes, we need and want to set up a process for registering _DSD=20
properties.  That turns out a bit more complicated than we thought it=20
would be, though.

No, that won't prevent people from doing insane things with properties=20
(or similar) they never register and they support in their=20
out-of-the-tree drivers they never attempt to mainline.  But let's be=20
honest that this can happen with DT just as well.

And it seems to me that we're spending more time on doing politics than=
=20
on solving technical problems which should really be our focus IMO.

And the underlying technical problem to me is what I said before: Devic=
e=20
drivers should work regardless of what way the configuration informatio=
n=20
is provided to the kernel.  Indeed, they shouldn't even have to care=20
about that.

Do you agree with that?

Thanks,
Rafael
