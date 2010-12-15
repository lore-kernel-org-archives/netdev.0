From: Michael Leun <lkml20101129@newton.leun.net>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Wed, 15 Dec 2010 01:24:30 +0100
Message-ID: <20101215012430.120fd47f@xenia.leun.net>
References: <1291536233.2806.102.camel@edumazet-laptop>
 <20101205105528.49fa9a9f@xenia.leun.net>
 <20101205114404.7c0cddc2@xenia.leun.net>
 <AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
 <20101206203437.54b550e0@xenia.leun.net>
 <AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
 <20101206222703.32fbe852@xenia.leun.net>
 <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
 <20101213224510.GB17400@mcarlson.broadcom.com>
 <AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
 <20101214191500.GD19951@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jesse Gross" <jesse@nicira.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"Ben Greear" <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214191500.GD19951@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Dec 2010 11:15:00 -0800
"Matt Carlson" <mcarlson@broadcom.com> wrote:

> On Mon, Dec 13, 2010 at 08:07:20PM -0800, Jesse Gross wrote:
> > On Mon, Dec 13, 2010 at 2:45 PM, Matt Carlson
> > <mcarlson@broadcom.com> wrote:
> > > On Sun, Dec 12, 2010 at 04:11:13PM -0800, Jesse Gross wrote:
> > >> On Mon, Dec 6, 2010 at 1:27 PM, Michael Leun
> > >> <lkml20101129@newton.leun.net> wrote:
> > >> > On Mon, 6 Dec 2010 12:04:48 -0800
> > >> > Jesse Gross <jesse@nicira.com> wrote:
> > >> >
> > >> >> On Mon, Dec 6, 2010 at 11:34 AM, Michael Leun
> > >> >> <lkml20101129@newton.leun.net> wrote:
> > >> >> > On Mon, 6 Dec 2010 10:14:55 -0800
> > >> >> > Jesse Gross <jesse@nicira.com> wrote:
> > >> >> >
> > >> >> >> On Sun, Dec 5, 2010 at 2:44 AM, Michael Leun
> > >> >> >> <lkml20101129@newton.leun.net> wrote:
> > >> >> >> > Hi Jesse,
> > >> >> >> >
> > >> >> >> > On Sun, 5 Dec 2010 10:55:28 +0100
> > >> >> >> > Michael Leun <lkml20101129@newton.leun.net> wrote:
> > >> >> >> >
> > >> >> >> >> On Sun, 05 Dec 2010 09:03:53 +0100
> > >> >> >> >> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > >> >> >> >>
> > >> >> >> >> > > But on
> > >> >> >> >> > >
> > >> >> >> >> > > hpdl320g5:/home/ml # lspci | grep Eth
> > >> >> >> >> > > 03:04.0 Ethernet controller: Broadcom Corporation
> > >> >> >> >> > > NetXtreme BCM5714 Gigabit Ethernet (rev a3) 03:04.1
> > >> >> >> >> > > Ethernet controller: Broadcom Corporation NetXtreme
> > >> >> >> >> > > BCM5714 Gigabit Ethernet (rev a3)
> > >> >> >> >> > >
> > >> >> >> >> > > the good message is that it also does not crash,
> > >> >> >> >> > > but with tcpdump I see vlan tags when no vlan
> > >> >> >> >> > > devices configured on the respective eth, if so I
> > >> >> >> >> > > do not see tags anymore vlan tags on the trunk
> > >> >> >> >> > > interface.
> > >> >> >> >> > >
> > >> >> >> >> >
> > >> >> >> >> > For all these very specific needs, you'll have to try
> > >> >> >> >> > 2.6.37 I am afraid. Jesse did huge changes to exactly
> > >> >> >> >> > make this working, we wont backport this to 2.6.36,
> > >> >> >> >> > but only avoid crashes.
> > >> >> >> >>
> > >> >> >> >> OK, I'm perfectly fine with that, of course, actually
> > >> >> >> >> nice to hear that the issue already is addressed.
> > >> >> >> >>
> > >> >> >> >> Likely I'll give some rc an shot on this machine (maybe
> > >> >> >> >> over christmas), but it is an production machine
> > >> >> >> >> (acutally testing other devices is the "product"
> > >> >> >> >> produced on this machine), so unfortunately I'm not
> > >> >> >> >> that free in when and what I can do (but the
> > >> >> >> >> possibility to, for example, bridge the trunk interface
> > >> >> >> >> would make testing easier, that justifies something...).
> > >> >> >> >>
> > >> >> >> >> Thank you all very much for your work.
> > >> >> >> >
> > >> >> >> > Are these changes already in 2.6.37-rc4? Or, if not are
> > >> >> >> > they somewhere publically available already?
> > >> >> >> >
> > >> >> >> > I looked into various changelogs but have some
> > >> >> >> > difficulties to identify them...
> > >> >> >> >
> > >> >> >> > Maybe I have some time next days to give them an try...
> > >> >> >>
> > >> >> >> Yes, all of the existing vlan changes are in
> > >> >> >> 2.6.37-rc4. ?There were a number of patches but the main
> > >> >> >> one was 3701e51382a026cba10c60b03efabe534fba4ca4
> > >> >> >
> > >> >> > Then, I'm afraid, this (seeing vlan tags even if vlan
> > >> >> > interfaces are configured) does not work on HP DL320G5 (for
> > >> >> > exact description and examples please see my mail a few
> > >> >> > days ago).
> > >> >>
> > >> >> What driver are you using? ?Is it tg3?
> > >> >>
> > >> >> The vlan changes that I made unfortunately require updating
> > >> >> drivers to get the full benefit. ?I've been busy lately so
> > >> >> tg3 hasn't yet been updated.
> > >> >>
> > >> >> I know that tg3 does some things differently depending on
> > >> >> whether a vlan group is configured, so that would likely be
> > >> >> the cause of what you are seeing. ?I'd have to look at it in
> > >> >> more detail to be sure though.
> > >> >>
> > >> >> You said that everything works on the other Broadcom NIC that
> > >> >> you tested? ?Maybe it uses bnx2 instead?
> > >> >>
> > >> >
> > >> > Both machines use tg3 / 2.6.36.1 - one is opensuse, one ubuntu
> > >> > (but this should not matter, I think).
> > >> >
> > >> > If I can do anything to support your investigations / work
> > >> > (most likely testing / providing information) please let me
> > >> > know.
> > >>
> > >> Unfortunately, I probably won't have time to look at this in the
> > >> near future. ?Given that the test works on one NIC but not
> > >> another that strongly suggests that it is a driver problem, even
> > >> if both NICs use the same driver. ?I see tg3 can do different
> > >> things with vlans depending on the model and what features are
> > >> enabled. ?I also ran a quick test on some of my machines and I
> > >> didn't experience this issue. They are running net-next with
> > >> ixgbe.
> > >>
> > >> One of the main goals of my general vlan changes was to remove
> > >> as much logic as possible from the drivers and put it in the
> > >> networking core, so we should in theory see consistent
> > >> behavior. ?However, in 2.6.36 and earlier, each driver knows
> > >> about what vlan devices are configured and does different things
> > >> with that information.
> > >>
> > >> Given all of that, the most logical step to me is simply to
> > >> convert tg3 to use the new vlan infrastructure. ?It should be
> > >> done regardless and it will probably solve this problem. ?Maybe
> > >> you can convince the Broadcom guys to do that? ?It would be a
> > >> lot faster for them to do it than me.
> > >
> > > Below is the patch that converts the tg3 driver over to the new
> > > API. ?I don't see how it could fix the problem though. ?Maybe the
> > > presence of NETIF_F_HW_VLAN_TX changes things.
> > 
> > Thanks Matt.
> > 
> > There's actually a little bit more that needs to be done for
> > conversion.  All references to the vlan group should be gone since
> > that logic has been moved to the networking core.
> > tg3_vlan_rx_register() completely disappears and all other code
> > contained in TG3_VLAN_TAG_USED is unconditionally active.  Ideally,
> > there would be an Ethtool set_flags function so that the vlan
> > offloading features could be enabled/disabled for situations like
> > this to help with debugging.
> > 
> > The reason why I think that this might help is that the problem
> > manifests when a vlan group is configured, even if that vlan isn't
> > used.  Since this removes all logic about vlan groups from the
> > driver, it should avoid any problems in that area.  It's possible
> > that the actual issue is somewhere else but then it should be
> > easier to find since we can separate out the different components.
> 
> Thanks for the comments Jesse.  Below is an updated patch.
> 
> Michael, I'm wondering if the difference in behavior can be explained
> by the presence or absence of management firmware.  Can you look at
> the driver sign-on messages in your syslogs for ASF[]?  I'm half
> expecting the 5752 to show "ASF[0]" and the 5714 to show "ASF[1]".
> If you see this, and the below patch doesn't fix the problem, let me
> know.  I have another test I'd like you to run.

Do I understand this correct? "Management firmware" or ASF is some
feature, vendor decides to built into network card (firmware) or not?

If so, would'nt one expect two oneboard network cards in one server
to look alike?

HP Proliant DL320G5

<6>tg3.c:v3.113 (August 2, 2010)
<6>tg3 0000:03:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
<6>tg3 0000:03:04.0: eth0: Tigon3 [partno(N/A) rev 9003] (PCIX:133MHz:64-bit) MAC address xx:xx:xx:xx:xx:xx
<6>tg3 0000:03:04.0: eth0: attached PHY is 5714 (10/100/1000Base-T Ethernet) (WireSpeed[1])
<6>tg3 0000:03:04.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
<6>tg3 0000:03:04.0: eth0: dma_rwctrl[76148000] dma_mask[64-bit]
<6>tg3 0000:03:04.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
<6>tg3 0000:03:04.1: eth1: Tigon3 [partno(N/A) rev 9003] (PCIX:133MHz:64-bit) MAC address xx:xx:xx:xx:xx:xx
<6>tg3 0000:03:04.1: eth1: attached PHY is 5714 (10/100/1000Base-T Ethernet) (WireSpeed[1])
<6>tg3 0000:03:04.1: eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
<6>tg3 0000:03:04.1: eth1: dma_rwctrl[76148000] dma_mask[64-bit]

Lenovo ThinkPad z61m

[    2.679130] tg3.c:v3.113 (August 2, 2010)
[    2.679176] tg3 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    2.679188] tg3 0000:02:00.0: setting latency timer to 64
[    2.728572] tg3 0000:02:00.0: eth0: Tigon3 [partno(BCM95752m) rev 6002] (PCI Express) MAC address xx:xx:xx:xx:xx:xx
[    2.728577] tg3 0000:02:00.0: eth0: attached PHY is 5752 (10/100/1000Base-T Ethernet) (WireSpeed[1])
[    2.728581] tg3 0000:02:00.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[    2.728585] tg3 0000:02:00.0: eth0: dma_rwctrl[76180000]
dma_mask[64-bit]


> ----
> 
> [PATCH] tg3: Use new VLAN code

Unfortunately had'nt time to try much now, but with 2.6.37-rc5 / your
patch on the DL320, single user mode (nothing configured on eth) just
after ifconfig eth0/eth1 up I see NO vlan tags on eth0 but I see vlan
tags on eth1, so there clearly is a difference.

I should have checked if I still see vlan tags on eth1 if I configure
some vlan there - if helpful maybe I can do this (have to look, when I
can effort another downtime).

I wonder, if the difference in that both onboard cards is really there
or if there is some malfunction in detecion?

-- 
MfG,

Michael Leun
