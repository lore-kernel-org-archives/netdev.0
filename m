From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not used
Date: Mon, 13 Dec 2010 20:07:20 -0800
Message-ID: <AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
References: <1291200914.2856.546.camel@edumazet-laptop>
	<20101205030712.36149bc2@xenia.leun.net>
	<1291536233.2806.102.camel@edumazet-laptop>
	<20101205105528.49fa9a9f@xenia.leun.net>
	<20101205114404.7c0cddc2@xenia.leun.net>
	<AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
	<20101206203437.54b550e0@xenia.leun.net>
	<AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
	<20101206222703.32fbe852@xenia.leun.net>
	<AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
	<20101213224510.GB17400@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Leun <lkml20101129@newton.leun.net>,
	Michael Chan <mchan@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101213224510.GB17400@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 13, 2010 at 2:45 PM, Matt Carlson <mcarlson@broadcom.com> w=
rote:
> On Sun, Dec 12, 2010 at 04:11:13PM -0800, Jesse Gross wrote:
>> On Mon, Dec 6, 2010 at 1:27 PM, Michael Leun
>> <lkml20101129@newton.leun.net> wrote:
>> > On Mon, 6 Dec 2010 12:04:48 -0800
>> > Jesse Gross <jesse@nicira.com> wrote:
>> >
>> >> On Mon, Dec 6, 2010 at 11:34 AM, Michael Leun
>> >> <lkml20101129@newton.leun.net> wrote:
>> >> > On Mon, 6 Dec 2010 10:14:55 -0800
>> >> > Jesse Gross <jesse@nicira.com> wrote:
>> >> >
>> >> >> On Sun, Dec 5, 2010 at 2:44 AM, Michael Leun
>> >> >> <lkml20101129@newton.leun.net> wrote:
>> >> >> > Hi Jesse,
>> >> >> >
>> >> >> > On Sun, 5 Dec 2010 10:55:28 +0100
>> >> >> > Michael Leun <lkml20101129@newton.leun.net> wrote:
>> >> >> >
>> >> >> >> On Sun, 05 Dec 2010 09:03:53 +0100
>> >> >> >> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >> >> >>
>> >> >> >> > > But on
>> >> >> >> > >
>> >> >> >> > > hpdl320g5:/home/ml # lspci | grep Eth
>> >> >> >> > > 03:04.0 Ethernet controller: Broadcom Corporation NetXt=
reme
>> >> >> >> > > BCM5714 Gigabit Ethernet (rev a3) 03:04.1 Ethernet
>> >> >> >> > > controller: Broadcom Corporation NetXtreme BCM5714 Giga=
bit
>> >> >> >> > > Ethernet (rev a3)
>> >> >> >> > >
>> >> >> >> > > the good message is that it also does not crash, but wi=
th
>> >> >> >> > > tcpdump I see vlan tags when no vlan devices configured=
 on
>> >> >> >> > > the respective eth, if so I do not see tags anymore vla=
n
>> >> >> >> > > tags on the trunk interface.
>> >> >> >> > >
>> >> >> >> >
>> >> >> >> > For all these very specific needs, you'll have to try 2.6=
=2E37
>> >> >> >> > I am afraid. Jesse did huge changes to exactly make this
>> >> >> >> > working, we wont backport this to 2.6.36, but only avoid
>> >> >> >> > crashes.
>> >> >> >>
>> >> >> >> OK, I'm perfectly fine with that, of course, actually nice =
to
>> >> >> >> hear that the issue already is addressed.
>> >> >> >>
>> >> >> >> Likely I'll give some rc an shot on this machine (maybe ove=
r
>> >> >> >> christmas), but it is an production machine (acutally testi=
ng
>> >> >> >> other devices is the "product" produced on this machine), s=
o
>> >> >> >> unfortunately I'm not that free in when and what I can do (=
but
>> >> >> >> the possibility to, for example, bridge the trunk interface
>> >> >> >> would make testing easier, that justifies something...).
>> >> >> >>
>> >> >> >> Thank you all very much for your work.
>> >> >> >
>> >> >> > Are these changes already in 2.6.37-rc4? Or, if not are they
>> >> >> > somewhere publically available already?
>> >> >> >
>> >> >> > I looked into various changelogs but have some difficulties =
to
>> >> >> > identify them...
>> >> >> >
>> >> >> > Maybe I have some time next days to give them an try...
>> >> >>
>> >> >> Yes, all of the existing vlan changes are in 2.6.37-rc4. ?Ther=
e
>> >> >> were a number of patches but the main one was
>> >> >> 3701e51382a026cba10c60b03efabe534fba4ca4
>> >> >
>> >> > Then, I'm afraid, this (seeing vlan tags even if vlan interface=
s are
>> >> > configured) does not work on HP DL320G5 (for exact description =
and
>> >> > examples please see my mail a few days ago).
>> >>
>> >> What driver are you using? ?Is it tg3?
>> >>
>> >> The vlan changes that I made unfortunately require updating drive=
rs to
>> >> get the full benefit. ?I've been busy lately so tg3 hasn't yet be=
en
>> >> updated.
>> >>
>> >> I know that tg3 does some things differently depending on whether=
 a
>> >> vlan group is configured, so that would likely be the cause of wh=
at
>> >> you are seeing. ?I'd have to look at it in more detail to be sure
>> >> though.
>> >>
>> >> You said that everything works on the other Broadcom NIC that you
>> >> tested? ?Maybe it uses bnx2 instead?
>> >>
>> >
>> > Both machines use tg3 / 2.6.36.1 - one is opensuse, one ubuntu (bu=
t
>> > this should not matter, I think).
>> >
>> > If I can do anything to support your investigations / work (most
>> > likely testing / providing information) please let me know.
>>
>> Unfortunately, I probably won't have time to look at this in the nea=
r
>> future. =A0Given that the test works on one NIC but not another that
>> strongly suggests that it is a driver problem, even if both NICs use
>> the same driver. =A0I see tg3 can do different things with vlans
>> depending on the model and what features are enabled. =A0I also ran =
a
>> quick test on some of my machines and I didn't experience this issue=
=2E
>> They are running net-next with ixgbe.
>>
>> One of the main goals of my general vlan changes was to remove as mu=
ch
>> logic as possible from the drivers and put it in the networking core=
,
>> so we should in theory see consistent behavior. =A0However, in 2.6.3=
6
>> and earlier, each driver knows about what vlan devices are configure=
d
>> and does different things with that information.
>>
>> Given all of that, the most logical step to me is simply to convert
>> tg3 to use the new vlan infrastructure. =A0It should be done regardl=
ess
>> and it will probably solve this problem. =A0Maybe you can convince t=
he
>> Broadcom guys to do that? =A0It would be a lot faster for them to do=
 it
>> than me.
>
> Below is the patch that converts the tg3 driver over to the new API. =
=A0I
> don't see how it could fix the problem though. =A0Maybe the presence =
of
> NETIF_F_HW_VLAN_TX changes things.

Thanks Matt.

There's actually a little bit more that needs to be done for
conversion.  All references to the vlan group should be gone since
that logic has been moved to the networking core.
tg3_vlan_rx_register() completely disappears and all other code
contained in TG3_VLAN_TAG_USED is unconditionally active.  Ideally,
there would be an Ethtool set_flags function so that the vlan
offloading features could be enabled/disabled for situations like this
to help with debugging.

The reason why I think that this might help is that the problem
manifests when a vlan group is configured, even if that vlan isn't
used.  Since this removes all logic about vlan groups from the driver,
it should avoid any problems in that area.  It's possible that the
actual issue is somewhere else but then it should be easier to find
since we can separate out the different components.
