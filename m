From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: Re: Merging SSB and HND/AI support
Date: Mon, 17 Jan 2011 14:43:08 +0100
Message-ID: <AANLkTims0DPfG+u9qynuuj_-0WjUr1nAGLuFz3k706T-@mail.gmail.com>
References: <AANLkTi=GDcy50zsC6=Dgv1-Ty3cYK2qpx9o=q3JdXuCh@mail.gmail.com>
 <1295261783.24530.3.camel@maggie> <AANLkTikJcug7LUTgX_YDD4Z8ZBrdkAdLq8_Epa6TkA5f@mail.gmail.com>
 <1295265468.24530.23.camel@maggie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-mips@linux-mips.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: =?UTF-8?Q?Michael_B=C3=BCsch?= <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:37455 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143Ab1AQNn2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 08:43:28 -0500
In-Reply-To: <1295265468.24530.23.camel@maggie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 January 2011 12:57, Michael B=C3=BCsch <mb@bu3sch.de> wrote:
> Well... I don't really like the idea of running one driver and
> subsystem implementation on completely distinct types of silicon.
> We will end up with the same mess that broadcom ended up with in
> their "SB" code (broadcom's SSB backplane implementation).
> For example, in their code the driver calls pci_enable_device() and
> related PCI functions, even if there is no PCI device at all. The cal=
ls
> are magically re-routed to the actual SB backplane.
> You'd have to do the same mess with SSB. Calling ssb_device_enable()
> will mean "enable the SSB device", if the backplane is SSB, and will
> mean "enable the HND/AI" device, if the backplane is HND/AI.

It didn't strike me as that bad, but I also didn't look at any PCI code=
=2E

> So I'm still in favor of doing a separate HND/AI bus implementation,
> even if
> that means duplicating a few lines of code.

Well, it means at least duplicating most of the chipcommon driver and
the mips core driver. But if you are fine with that, I see no problem
with having a separate driver for the AI bus.

> SSB doesn't search for SSB busses in the system, because there's no
> way to do so. The architecture (or the PCI/PCMCIA/SDIO device) regist=
ers
> the bus,
> if it detected an SSB device. So for the embedded case, it's hardcode=
d
> in the arch code. For the PCI case it simply depends on the PCI IDs.
> I don't see a problem here. Your arch code will already have to know
> what machine it is running on. So it will have to decide whether to
> register a SSB or HND/AI bus.

Okay. This is mostly for the embedded case, where it is possible to
create a single kernel that boots on both. The "detection" could also
be done through the cpu type (74k =3D> register AI bus, else SSB bus)
instead of the chipid register of the common core.

>> Also I don't know
>> if it is a good idea to let arch-specific code depend on code in
>> staging.
>
> Sure. The code needs to be cleaned up and moved to the mainline kerne=
l
> _anyway_. You don't get around this.

Yes, you are right.


So I guess the proposed course of action would be:

1. Make the HND/AI-Bus code from brcm80211 its own independent driver,
2. Re-add the non-wifi related code (chipcommon, mips, etc),
3. Clean up the code until it meets Linux' code style/quality,
4. Move it out of staging,

and finally

5. Add the required arch specific code to bcm47xx for the newer SoCs.

Jonas

P.S: Any suggestions for the name? Would be "ai" okay? Technically
it's "AMBA Interconnect", but "amba" is already taken.
