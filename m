From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Thu, 22 Mar 2012 06:38:47 -0700
Message-ID: <CAB=NE6U=Dq6h-2GuFR+8eYfBLT4vvB-EvqM-1Mc0t4oow+3GTw@mail.gmail.com>
References: <157393863283F442885425D2C4542856194154FC@nasanexd02a.na.qualcomm.com>
 <20120228.212857.797446903975232476.davem@davemloft.net> <157393863283F442885425D2C454285619415561@nasanexd02a.na.qualcomm.com>
 <20120228.223258.2261979237568571219.davem@davemloft.net> <CAB=NE6W-CYjEhbfYOv7XqXFGvdhZxRECqfAmgouaa5_j45gnOQ@mail.gmail.com>
 <20120322092727.GA21284@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, xiong@qca.qualcomm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	kgiori@qca.qualcomm.com, chris.snook@gmail.com,
	mathieu@qca.qualcomm.com, bryanh@quicinc.com,
	Jesper Andersen <jespera@diku.dk>, Julia Lawall <julia@diku.dk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120322092727.GA21284@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2012 at 2:27 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Luis R. Rodriguez <rodrigue@qca.qualcomm.com> :
>> On Tue, Feb 28, 2012 at 7:32 PM, David Miller <davem@davemloft.net> wrote:
> [...]
>> > To be honest tg3, as one example, supports quite a large array of
>> > different pieces of hardware that use the same logical core.
>>
>> At certain point it becomes a pain in the ass to support older
>> chipsets, and simply easier to leave the older driver to rot.
>
> I would avoid saying such things while trying to sell a plan for a bright
> future of drivers maintained and supported by $BIGCORP. :o)

My statement was more from a resource dedication point of view, but
yes, I agree with your concern. I want to clarify that Atheros !=
Qualcomm. Atheros is now known as Qualcomm Atheros and what we do is
different than Qualcomm. Atheros proactively works upstream as a high
priority. Addressing legacy chipsets support is IMHO a definite
requirement when any $BIGCORP wants to work on addressing support
upstream in the Linux kernel (or any kernel).

> [...]
>> Would it be worthwhile to consider alx upstream only for the newer
>> chipsets (regardless of the litmus test, which I do agree with on
>> technical grounds) in consideration for helping pave the way on
>> killing proprietary drivers?
>
> What is the situation regarding the availability for public use of
> programming manuals and errata on older chipsets ?

Atheros has provided documentation for at least 802.11 chipsets for
older and even newer chipsets to interested active community
developers, to the extent we have also even released GPLv2 open
firmware through ar9170.fw [0] which resulted in fork of that firmware
carl9170.fw [1] and new shiny driver carl9170 [2].

The way we work with the community on providing documentation has been
on a case by case basis and documentation has also been evaluated as
such. Over the last year we have been formalizing this process a bit
further and trying to categorize documentation moving forward so that
it is easier for engineering groups for different types of
technologies to work with the community and enable the community as
best as possible. We now have a program called, the QCA Developer
Program, not documented anywhere but in practice already used widely
by QCA, which has for instance, already enabled quite a bit of DFS
code upstream for ath9k, and a few developers are enabled for other
things, one of which we hope is to enable development of open firmware
for ath9k_htc [3] to set the precedent of success for it even further.

So -- for Ethernet I see it not different, lets leave history behind
and focus on enabling developers as best as possible. If there is
documentation available internally we should revise it, categorize it
and see to it that we enable developers as best as possible, in
whatever way we can.

> I am fine with Qualcomm being completely uninterested in maintaining
> code for old chipsets and dedicating manpower or $$$ on it, be it now,
> tomorrow or after a new arrival of management execs. However it sends
> a bad message if code for new chipsets comes in while users have to
> maintain their pile of poo in the dark.

Agreed 100%

> The hardware stays for years. It's one of the engineering problems of
> the day.

Sure.

> Killing proprietary drivers is an interesting goal but it is
> far, far away.

This is why progress isn't made. Talk is cheap. Lets just get it done.

> Qualcomm should imvho meet davem's remarks with more short termed
> deliverables.

I don't disagree based on technical grounds, what I stated was more as
a review in consideration of goals of sharing code. I did review the
possibility of sticking to atl1c to help with the evolutionary changes
there instead and while I believe that is the right technical
approach, legally from a sharing point of view, the atl1c is
derivative works of the Intel e1000 driver and the e1000 driver has
changes even before git days of the kernel. Relicensing atl1c to ISC
license, which is another option, therefore extremely difficult, but
one option I did review.

Either way, I am happy we follow the general direction given, I just
wanted to make one last point on using alx based on sharing objectives
and as a good simple technical use case of trying to help kill
proprietary drivers for good. I'm fine with alx not being the pivotal
point for us but given Ethernet's simplicity it seems ideal to
consider given the objectives and I felt compelled to address that one
last point given the small set of other options we have.

[0] http://wireless.kernel.org/en/users/Drivers/ar9170.fw
[1] http://wireless.kernel.org/en/users/Drivers/carl9170.fw
[2] http://wireless.kernel.org/en/users/Drivers/carl9170
[3] http://wireless.kernel.org/en/developers/GSoC/2012/ath9k_htc_open_firmware

  Luis
