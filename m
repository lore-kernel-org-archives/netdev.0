From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Fri, 07 Jan 2011 04:54:48 +0100
Message-ID: <1294372488.2704.61.camel@edumazet-laptop>
References: <AANLkTinq9ABi0prxe0m1Ma6rno4UnAOzuW-b5L362ij9@mail.gmail.com>
	 <1293984348.2535.101.camel@edumazet-laptop>
	 <AANLkTincX-wPQE9gs16v53E4=Skivzc4ZSJS43oNBLD_@mail.gmail.com>
	 <1294356887.2704.13.camel@edumazet-laptop>
	 <1294363201.2704.19.camel@edumazet-laptop>
	 <20110107022912.GA17757@mcarlson.broadcom.com>
	 <1294368071.2704.49.camel@edumazet-laptop>
	 <1294368202.2704.50.camel@edumazet-laptop>
	 <20110107025930.GA17808@mcarlson.broadcom.com>
	 <1294369486.2704.53.camel@edumazet-laptop>
	 <20110107034130.GA18028@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	Michael Leun <lkml20101129@newton.leun.net>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110107034130.GA18028@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 06 janvier 2011 =C3=A0 19:41 -0800, Matt Carlson a =C3=A9crit =
:
> On Thu, Jan 06, 2011 at 07:04:46PM -0800, Eric Dumazet wrote:
> > Le jeudi 06 janvier 2011 ?? 18:59 -0800, Matt Carlson a ??crit :
> > > On Thu, Jan 06, 2011 at 06:43:22PM -0800, Eric Dumazet wrote:
> > > > Le vendredi 07 janvier 2011 ?? 03:41 +0100, Eric Dumazet a ??cr=
it :
> > > > > Le jeudi 06 janvier 2011 ?? 18:29 -0800, Matt Carlson a ??cri=
t :
> > > > >=20
> > > > > > Hi Eric.  Sorry for the delay.  I was under the impression =
that your
> > > > > > problems were software related and that you just needed a r=
evised
> > > > > > version of these VLAN patches I was sending to Michael.  Is=
 this not
> > > > > > true?
> > > > > >=20
> > > > > > Having a hardware stat increment suggests this is a new pro=
blem.
> > > > > > Maybe I missed it, but I didn't see what hardware you are w=
orking
> > > > > > with and whether or not management firmware was enabled.  C=
ould you tell
> > > > > > me that info?
> > > > > >=20
> > > > >=20
> > > > > Hi Matt
> > > > >=20
> > > > > I started a bisection, because I couldnt sleep tonight anyway=
 :(
> > > > >=20
> > > > > 14:04.0 Ethernet controller: Broadcom Corporation NetXtreme B=
CM5715S
> > > > > Gigabit Ethernet (rev a3)
> > > > > 	Subsystem: Hewlett-Packard Company NC326m PCIe Dual Port Ada=
pter
> > > > > 	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 43
> > > > > 	Memory at fdff0000 (64-bit, non-prefetchable) [size=3D64K]
> > > > > 	Memory at fdfe0000 (64-bit, non-prefetchable) [size=3D64K]
> > > > > 	[virtual] Expansion ROM at fdbe0000 [disabled] [size=3D128K]
> > > > > 	Capabilities: [40] PCI-X non-bridge device
> > > > > 	Capabilities: [48] Power Management version 2
> > > > > 	Capabilities: [50] Vital Product Data
> > > > > 	Capabilities: [58] MSI: Enable+ Count=3D1/8 Maskable- 64bit+
> > > > > 	Kernel driver in use: tg3
> > > > > 	Kernel modules: tg3
> > > > >=20
> > > > >=20
> > > >=20
> > > > $ ethtool -i eth2
> > > > driver: tg3
> > > > version: 3.115
> > > > firmware-version: 5715s-v3.28
> > > > bus-info: 0000:14:04.0
> > > > $ dmesg | grep ASF
> > > > [    6.220577] tg3 0000:14:04.0: eth2: RXcsums[1] LinkChgREG[0]=
 MIirq[0]
> > > > ASF[0] TSOcap[1]
> > > > [    6.228586] tg3 0000:14:04.1: eth3: RXcsums[1] LinkChgREG[0]=
 MIirq[0]
> > > > ASF[0] TSOcap[1]
> > >=20
> > > Thanks.  So management firmware is disabled.  This should be
> > > straightforward case.
> > >=20
> > > I'm wondering if I'm misunderstanding something though.  You said=
 earlier
> > > that VLAN tagging doesn't work unless you applied my patch.  Is t=
his no
> > > longer true?
> > >=20
> >=20
> > I dont apply your patch because Jesse said it was not a good patch =
;)
>=20
> Oh.
>=20
> > Maybe I missed something and it must be applied ? Problem is : curr=
ent
> > Linus tree now includes net-next-2.6 and vlan doesnt work. You shou=
ld
> > resubmit it perhaps ?
>=20
> Yes, something needs to be submitted.  I want to make sure we aren't
> chasing the same problem though.  If the patch(es) fix your problem,
> then I can concentrate on finalizing the patch.
>=20

I believe it did, I can test your next patch ;)

> I can combine my last patch (the one that always enabled VLAN tag
> stripping) and the previous patch (that implements all your comments =
so
> far) into one patch, but that still leaves the behavior Michael noted
> unaddressed.
>=20
> Michael, did you ever find out whether or not RXD_FLAG_VLAN was being
> set?
>=20

Here is the bisect log , just in case :

d2394e6bb1aa636f3bd142cb6f7845a4332514b5 is first bad commit
commit d2394e6bb1aa636f3bd142cb6f7845a4332514b5
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Wed Nov 24 08:31:47 2010 +0000

    tg3: Always turn on APE features in mac_mode reg
   =20
    The APE needs certain bits in the mac_mode register to be enabled f=
or
    traffic to flow correctly.  This patch changes the code to always e=
nable
    these bits in the presence of the APE.
   =20
    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Michael Chan <mchan@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 086382ce3ecd909222faf53ca23c48d1200dd60c 0a325ac6e7aa87a=
6737610292ab3025156a4ed80 M	drivers



$ git bisect log
git bisect start
# bad: [3c0cb7c31c206aaedb967e44b98442bbeb17a6c4] Merge branch 'devel' =
of master.kernel.org:/home/rmk/linux-2.6-arm
git bisect bad 3c0cb7c31c206aaedb967e44b98442bbeb17a6c4
# good: [3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5] Linux 2.6.37
git bisect good 3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5
# bad: [63e35cd9bd4c8ae085c8b9a70554595b529c4100] Merge branch 'master'=
 of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-nex=
t-2.6 into for-davem
git bisect bad 63e35cd9bd4c8ae085c8b9a70554595b529c4100
# bad: [67d5288049f46f816181f63eaa8f1371877ad8ea] vxge: update driver v=
ersion
git bisect bad 67d5288049f46f816181f63eaa8f1371877ad8ea
# good: [b382b191ea9e9ccefc437433d23befe91f4a8925] ipv6: AF_INET6 link =
address family
git bisect good b382b191ea9e9ccefc437433d23befe91f4a8925
# good: [bedbbb959d2c1d1dbb4c2215f5b7074b1da3030a] ath: Add a driver_in=
fo bitmask field
git bisect good bedbbb959d2c1d1dbb4c2215f5b7074b1da3030a
# bad: [cf7afbfeb8ceb0187348d0a1a0db61305e25f05f] rtnl: make link af-sp=
ecific updates atomic
git bisect bad cf7afbfeb8ceb0187348d0a1a0db61305e25f05f
# good: [22674a24b44ac53f244ef6edadd02021a270df5a] Net: dns_resolver: M=
akefile: Remove deprecated kbuild goal definitions
git bisect good 22674a24b44ac53f244ef6edadd02021a270df5a
# bad: [cf79003d598b1f82a4caa0564107283b4f560e14] tg3: Fix 5719 interna=
l FIFO overflow problem
git bisect bad cf79003d598b1f82a4caa0564107283b4f560e14
# good: [094f2faaa2c4973e50979158f655a1d31a97ba98] Net: rds: Makefile: =
Remove deprecated items
git bisect good 094f2faaa2c4973e50979158f655a1d31a97ba98
# good: [04f6d70f6e64900a5d70a5fc199dd9d5fa787738] SELinux: Only return=
 netlink error when we know the return is fatal
git bisect good 04f6d70f6e64900a5d70a5fc199dd9d5fa787738
# good: [5093eedc8bdfd7d906836a44a248f66a99e27d22] tg3: Apply 10Mbps fi=
x to all 57765 revisions
git bisect good 5093eedc8bdfd7d906836a44a248f66a99e27d22
# bad: [d2394e6bb1aa636f3bd142cb6f7845a4332514b5] tg3: Always turn on A=
PE features in mac_mode reg
git bisect bad d2394e6bb1aa636f3bd142cb6f7845a4332514b5
# good: [b75cc0e4c1caac63941d96a73b2214e8007b934b] tg3: Assign correct =
tx margin for 5719
git bisect good b75cc0e4c1caac63941d96a73b2214e8007b934b
