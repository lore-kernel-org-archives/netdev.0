From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not used
Date: Sun, 12 Dec 2010 16:11:13 -0800
Message-ID: <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
References: <20101129201716.1d0257c4@xenia.leun.net>
	<4CF442FA.4070701@candelatech.com>
	<20101130095944.41b5f7b6@xenia.leun.net>
	<1291108809.2904.3.camel@edumazet-laptop>
	<20101201111716.424fb771@xenia.leun.net>
	<1291200914.2856.546.camel@edumazet-laptop>
	<20101205030712.36149bc2@xenia.leun.net>
	<1291536233.2806.102.camel@edumazet-laptop>
	<20101205105528.49fa9a9f@xenia.leun.net>
	<20101205114404.7c0cddc2@xenia.leun.net>
	<AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
	<20101206203437.54b550e0@xenia.leun.net>
	<AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
	<20101206222703.32fbe852@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Leun <lkml20101129@newton.leun.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101206222703.32fbe852@xenia.leun.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 6, 2010 at 1:27 PM, Michael Leun
<lkml20101129@newton.leun.net> wrote:
> On Mon, 6 Dec 2010 12:04:48 -0800
> Jesse Gross <jesse@nicira.com> wrote:
>
>> On Mon, Dec 6, 2010 at 11:34 AM, Michael Leun
>> <lkml20101129@newton.leun.net> wrote:
>> > On Mon, 6 Dec 2010 10:14:55 -0800
>> > Jesse Gross <jesse@nicira.com> wrote:
>> >
>> >> On Sun, Dec 5, 2010 at 2:44 AM, Michael Leun
>> >> <lkml20101129@newton.leun.net> wrote:
>> >> > Hi Jesse,
>> >> >
>> >> > On Sun, 5 Dec 2010 10:55:28 +0100
>> >> > Michael Leun <lkml20101129@newton.leun.net> wrote:
>> >> >
>> >> >> On Sun, 05 Dec 2010 09:03:53 +0100
>> >> >> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >> >>
>> >> >> > > But on
>> >> >> > >
>> >> >> > > hpdl320g5:/home/ml # lspci | grep Eth
>> >> >> > > 03:04.0 Ethernet controller: Broadcom Corporation NetXtrem=
e
>> >> >> > > BCM5714 Gigabit Ethernet (rev a3) 03:04.1 Ethernet
>> >> >> > > controller: Broadcom Corporation NetXtreme BCM5714 Gigabit
>> >> >> > > Ethernet (rev a3)
>> >> >> > >
>> >> >> > > the good message is that it also does not crash, but with
>> >> >> > > tcpdump I see vlan tags when no vlan devices configured on
>> >> >> > > the respective eth, if so I do not see tags anymore vlan
>> >> >> > > tags on the trunk interface.
>> >> >> > >
>> >> >> >
>> >> >> > For all these very specific needs, you'll have to try 2.6.37
>> >> >> > I am afraid. Jesse did huge changes to exactly make this
>> >> >> > working, we wont backport this to 2.6.36, but only avoid
>> >> >> > crashes.
>> >> >>
>> >> >> OK, I'm perfectly fine with that, of course, actually nice to
>> >> >> hear that the issue already is addressed.
>> >> >>
>> >> >> Likely I'll give some rc an shot on this machine (maybe over
>> >> >> christmas), but it is an production machine (acutally testing
>> >> >> other devices is the "product" produced on this machine), so
>> >> >> unfortunately I'm not that free in when and what I can do (but
>> >> >> the possibility to, for example, bridge the trunk interface
>> >> >> would make testing easier, that justifies something...).
>> >> >>
>> >> >> Thank you all very much for your work.
>> >> >
>> >> > Are these changes already in 2.6.37-rc4? Or, if not are they
>> >> > somewhere publically available already?
>> >> >
>> >> > I looked into various changelogs but have some difficulties to
>> >> > identify them...
>> >> >
>> >> > Maybe I have some time next days to give them an try...
>> >>
>> >> Yes, all of the existing vlan changes are in 2.6.37-rc4. =A0There
>> >> were a number of patches but the main one was
>> >> 3701e51382a026cba10c60b03efabe534fba4ca4
>> >
>> > Then, I'm afraid, this (seeing vlan tags even if vlan interfaces a=
re
>> > configured) does not work on HP DL320G5 (for exact description and
>> > examples please see my mail a few days ago).
>>
>> What driver are you using? =A0Is it tg3?
>>
>> The vlan changes that I made unfortunately require updating drivers =
to
>> get the full benefit. =A0I've been busy lately so tg3 hasn't yet bee=
n
>> updated.
>>
>> I know that tg3 does some things differently depending on whether a
>> vlan group is configured, so that would likely be the cause of what
>> you are seeing. =A0I'd have to look at it in more detail to be sure
>> though.
>>
>> You said that everything works on the other Broadcom NIC that you
>> tested? =A0Maybe it uses bnx2 instead?
>>
>
> Both machines use tg3 / 2.6.36.1 - one is opensuse, one ubuntu (but
> this should not matter, I think).
>
> If I can do anything to support your investigations / work (most
> likely testing / providing information) please let me know.

Unfortunately, I probably won't have time to look at this in the near
future.  Given that the test works on one NIC but not another that
strongly suggests that it is a driver problem, even if both NICs use
the same driver.  I see tg3 can do different things with vlans
depending on the model and what features are enabled.  I also ran a
quick test on some of my machines and I didn't experience this issue.
They are running net-next with ixgbe.

One of the main goals of my general vlan changes was to remove as much
logic as possible from the drivers and put it in the networking core,
so we should in theory see consistent behavior.  However, in 2.6.36
and earlier, each driver knows about what vlan devices are configured
and does different things with that information.

Given all of that, the most logical step to me is simply to convert
tg3 to use the new vlan infrastructure.  It should be done regardless
and it will probably solve this problem.  Maybe you can convince the
Broadcom guys to do that?  It would be a lot faster for them to do it
than me.
