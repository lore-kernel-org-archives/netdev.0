From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c,
 take two
Date: Thu, 5 Apr 2012 16:21:58 +0200
Message-ID: <CAMuHMdURv7BN+7ai8MeMPxA770XM+VWhiKXXW4smc6P3V+6Lgg@mail.gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>
	<4F4B2BB6.900@gmail.com>
	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>
	<CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com>
	<4F5A0679.1020604@windriver.com>
	<4F7816B0.3090802@gmail.com>
	<4F7CB31D.8060002@windriver.com>
	<CAMuHMdWSzG4npwjpJ=cwNFKhyBZjvgPn1sp6nZ2re6QsRWPpXg@mail.gmail.com>
	<4F7D9D1B.3000801@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Schmitz <schmitzmic@googlemail.com>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4F7D9D1B.3000801@windriver.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

On Thu, Apr 5, 2012 at 15:24, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> On 12-04-05 05:28 AM, Geert Uytterhoeven wrote:
>> On Wed, Apr 4, 2012 at 22:46, Paul Gortmaker
>> <paul.gortmaker@windriver.com> wrote:
>>> On 12-04-01 04:49 AM, Michael Schmitz wrote:
>>>>> And on re-reading the comments in the other part of the patch, i.=
e.
>>>>> "...emulates the card interrupt via a timer" =C2=A0--perhaps the =
driver
>>>>> should be just fixed to support generic netpoll, instead of addin=
g
>>>>> an arch specific thing that amounts to netpoll. =C2=A0Then anyone=
 can
>>>>> attempt to limp along and use one of these ancient relics w/o IRQ=
=2E
>>>>>
>>>> Here's take two of my patch to convert the m68k Atari ROM port Eth=
ernet
>>>> driver to use mainstream ne.c, with minimal changes to the core NE=
2000
>>>> code.
>>>>
>>>> In particular:
>>>>
>>>> Changes to core net code:
>>>> * add a platform specific IRQ flag, so ne.c can share a hardware o=
r
>>>> timer interrupt with some other interrupt source.
>>>>
>>>> Changes to arch/m68k code:
>>>> * register the 8390 platform device on Atari only if the hardware =
is present
>>>> * retain the old driver (atari_ethernec.c in Geert's tree) under a
>>>> different config option, to be removed soon.
>>>>
>>>> Regarding your suggestion that netpoll be used instead of a dedica=
ted
>>>> timer interrupt: no changes to ne.c or 8390p.c are required to use
>>>> netpoll, it all works out of the box. All that is needed to use th=
e
>>>> driver with netpoll is setting the device interrupt to some source=
 that
>>>> can be registered, and enabling CONFIG_NETPOLL. Interrupt rate and=
 hence
>>>> throughput is lower with netpoll though, which is why I still pref=
er the
>>>> dedicated timer option.
>>>
>>> How much lower? =C2=A0Enough to matter? =C2=A0Implicit in that ques=
tion is
>>> the assumption that this is largely a hobbyist platform and nobody
>>> is using it in a closet to route gigabytes of traffic.
>>
>> One other thing we could do is increase CONFIG_HZ to 250.
>>
>>> Also, the only advantage to modifying ne.c is to allow dumping
>>> the old driver. =C2=A0What is the "remove soon" plan? =C2=A0Any rea=
son
>>> for it to not be synchronous? =C2=A0That would eliminate the Kconfi=
g
>>> churn and the introduction of the _OLD option. =C2=A0Modifying ne.c
>>> and then deciding to keep the old driver because it is "faster"
>>> would make this change pointless.
>>
>> From my point of view, "remove soon" means it will never hit mainlin=
e.
>
> Can you clarify what "it" is? =C2=A0 It isn't clear to me if you
> mean the _removal_ will never hit mainline, or the transient
> renamed "old" driver will never hit mainline.
>
> If the former, then there is no point pursuing this any further
> as I said above.
>
> If the latter, then the commit sent out for review should have
> no instances of this "renaming to old" related changes.

Sorry for being unclear. The latter (i.e. the old driver will
never hit mainline).

And Michael's patch against ne.c should indeed not touch the old
driver, as it doesn't exist in mainline.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
