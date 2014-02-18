From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] net: add init-regs for of_phy support
Date: Tue, 18 Feb 2014 08:16:46 +0000
Message-ID: <530316EE.5010104@codethink.co.uk>
References: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk> <1392642484-19938-2-git-send-email-ben.dooks@codethink.co.uk> <CAGVrzcYbw5xLj-gwcup5i0gBdKDDGdyy5wAaEBp7m2E7f2bytg@mail.gmail.com> <5302801F.6000903@cogentembedded.com> <CAGVrzcbZC3t0oexc5Aj-KyGj-qC8J9eYp8+rb8V-AqKtrSjyYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Mark Rutland <mark.rutland@arm.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcbZC3t0oexc5Aj-KyGj-qC8J9eYp8+rb8V-AqKtrSjyYw@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/02/14 20:48, Florian Fainelli wrote:

[snip]

>>> - fixing up some design mistake?
>>> - accounting for a specific board design?
>>
>>
>>     Kind of both. This was invented to defy the necessity of having platform
>> fixup in the DT case (where there should be no board file to place it into).
>> I have already described that platform fixup necessary on the Renesas
>> Lager/Koelsch boards where the LED0 signat is connected to ETH_LINK signal
>> on the SoC and the PHY reset sets the LED control bits to default 0 which
>> means that LED0 will be LINK/ACTIVITY signal and thus blink on activity and
>> cause ETH_LINK to bounce off/on after each packet.
>>
>>
>>> In any case a PHY fixup would do the job for you.
>>
>>
>>     Not in any case. In case of DT we have no place for it, so should invent
>> something involving DT.
>
> How is DT different than any machine probing mechanism here? The way
> to involve DT is to do the following:
>
> if (of_machine_is_compatible("renesas,foo-board-with-broken-micrel-phy"))
>             phy_register_fixup(&foo_board_with_broken_micrel_phy);

Oh yes, but now I have to do that for Linux, for $BSD, and for
anything else I want to run on the device. I thought dt was meant
to allow us to describe the hardware.

If this is the case, let's just call this linuxtree and let everyone
else get on with their own thing again.

See also comment below.

> If your machine compatible string does not allow you to uniquely
> identify your machine, this is a DT problem, as this should really be
> the case. If you do not want to add this code to wherever this is
> relevant in arch/arm/mach-shmobile/board-*.c, neither is
> drivers/net/phy/phy_device.c this the place to add it.

So where should it be added? If we keep piling stuff into board files
in arch/arm.... then we're just back to the pre-dt case and going to
keep getting shouted at.

> Dealing with quirks applying to industry standard blocks is to update
> the relevant driver, based on information provided by the specifically
> affected systems. Failure to identify either of those correctly is a
> problem that must not lead to a generic "let's override PHY registers
> from DT" type of solution.
>
> As usual, mechanism vs policy applies even more when DT is involved.

There's an industry standard for the access method, but every PHY seems
to have different extra setup registers for their own cases.

I will leave this out here in case anyone else finds it useful, there
may be a case where there are PHYs that need an amount of register
initialisation and this code may be smaller than putting a pile of
dt properties in.


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
