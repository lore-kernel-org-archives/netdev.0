From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: Re: [PATCH 0/3] drivers: net: cpsw: phy-handle fixes
Date: Wed, 23 Dec 2015 20:18:16 -0500
Message-ID: <20151223201816.1a4bd0f6.drivshin.allworx@gmail.com>
References: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
	<CABr+WT=oDpp56jouAD57UM8_38geD1MMizZcDnx14maf2ohpCw@mail.gmail.com>
	<20151223165454.6e4d5950.drivshin.allworx@gmail.com>
	<CABr+WTm=Oo16=qB6dyO6ZhUUz0307ROi=o270Rac2R4W5-usjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	devicetree@vger.kernel.org,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>,
	linux-omap@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>, Heiko Schocher <hs@denx.de>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Nicolas Chauvet <kwizart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34892 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbbLXBSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 20:18:20 -0500
In-Reply-To: <CABr+WTm=Oo16=qB6dyO6ZhUUz0307ROi=o270Rac2R4W5-usjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Dec 2015 00:34:49 +0100
Nicolas Chauvet <kwizart@gmail.com> wrote:

> 2015-12-23 22:54 GMT+01:00 David Rivshin (Allworx) <
> drivshin.allworx@gmail.com>:
> 
> > On Wed, 23 Dec 2015 22:20:58 +0100
> > Nicolas Chauvet <kwizart@gmail.com> wrote:
> >
> > > 2015-12-23 1:36 GMT+01:00 David Rivshin (Allworx) <
> > > drivshin.allworx@gmail.com>:
> > >
> > > > From: David Rivshin <drivshin@allworx.com>
> > > >
> > > > This series is based on the tip of the net tree.
> > > >
> > > > The first patch fixes a bug that makes dual_emac mode break if
> > > > either slave uses the phy-handle property in the devicetree.
> > > >
> > > > The second patch fixes some cosmetic problems with error
> > > > messages, and also makes the binding documentation more
> > > > explicit.
> > > >
> > > > The third patch cleans up the fixed-link case to work like
> > > > the now-fixed phy-handle case.
> > > >
> > > > I have tested on the following hardware configurations:
> > > >  - (EVMSK) dual emac, phy_id property in both slaves
> > > >  - (BeagleBoneBlack) single emac, phy_id property
> > > >  - (custom) single emac, fixed-link subnode
> > > > Note that I don't have a board which would uses a phy-handle
> > > > property, though I have used hacked devicetrees to exercise the
> > > > code paths. Testing by anyone who has real hardware using
> > > > phy-handle or dual_emac with fixed-link would be appreciated.
> > > >
> > > > David Rivshin (3):
> > > >   drivers: net: cpsw: fix parsing of phy-handle DT property in
> > > > dual_emac config
> > > >   drivers: net: cpsw: fix error messages when using phy-handle
> > > > DT property
> > > >   drivers: net: cpsw: use of_phy_connect() in fixed-link case
> > > >
> > > >  Documentation/devicetree/bindings/net/cpsw.txt |  4 +--
> > > >  drivers/net/ethernet/ti/cpsw.c                 | 40
> > > > +++++++++++++-------------
> > > >  drivers/net/ethernet/ti/cpsw.h                 |  1 +
> > > >  3 files changed, 23 insertions(+), 22 deletions(-)
> > > >
> > > >
> > > This serie failed with me on dm8418 hp-t410 on top of linux-next
> > > from today whereas the same patch level and same methods without
> > > this serie is working fine.
> > > I wasn't able to ping anything on a minimal rootfs with static ip
> > > set from cmdline from kernel.
> > >
> > > Sorry for  the lack of details, feel free to add me to any other
> > > revision of the patch if any.
> > > I will be able to do more testing next month.
> >
> > (Sorry for the duplicate, doing a reply-all this time. Not sure why
> > it looked like a non-list email the first time)
> >
> My bad, I've replied twice, but only last on-list.
> 
> 
> > Thanks for testing. I found the dm8148-t410.dts devicetree in the
> > kernel source, and it uses the phy_id for both slaves, just like the
> > EVMSK board I tested. So I can't think of an obvious reason for the
> > problem.
> > Would you be able to send the 'dmesg' log from right after bootup?
> > I'm hoping there is an error message in there with some clue.
> >
> here is the full dmesg output with this serie applied to linux-next:
> http://ur1.ca/ocvs6
> 
> [    2.281524] davinci_mdio 4a100800.mdio: davinci mdio revision 1.6
> [    2.287909] davinci_mdio 4a100800.mdio: detected phy mask fffffffe
> [    2.302663] Atheros 8031 ethernet 4a100800.mdio:00: GPIO lookup for
> consumer reset
> [    2.302686] Atheros 8031 ethernet 4a100800.mdio:00: using lookup
> tables for GPIO lookup
> [    2.302732] Atheros 8031 ethernet 4a100800.mdio:00: lookup for GPIO
> reset failed
> [    2.302860] libphy: 4a100800.mdio: probed
> [    2.307063] davinci_mdio 4a100800.mdio: phy[0]: device
> 4a100800.mdio:00, driver Atheros 8031 ethernet
> [    2.317945] cpsw 4a100000.ethernet: Detected MACID =
> 00:18:32:60:8e:38
> 
> * 19:06 < nchauvet> btw with this dmesg, I've tried to apply this
> serie: http://marc.info/?l=linux-omap&m=145032865615589&w=2, but it
> doesn't seem to work for me (I cannot ping my gateway anymore)

That particular email was about a v1 patch, which was then replaced
by a 3-patch series for v2:
http://marc.info/?l=linux-netdev&m=145032497014944&w=2
That is already in linux-next, and below you show that you have it.

> So I've remembered that I've double checked the Ethernet wire, but I
> agree it can also be another random issue.

If it works without this series, but fails with it, that is strong
evidence that something in this series either is a bug or exposes
one.

> > Just to verify, is your linux-next tree up-to-date? This series
> > needs to be applied is based on another recent series of 3 patches
> > to cpsw.c. Although I doubt it would apply cleanly at all without
> > those.
> 
> From my linux-next base, related to cpsw, I have:
> git log --oneline cpsw*
> a6b257c Merge remote-tracking branch 'net-next/master'
> dfc0a6d drivers: net: cpsw: increment reference count on fixed-link
> PHY node 
> f1eea5c drivers: net: cpsw: fix RMII/RGMII mode when used
> with fixed-link PHY
> 1873c58 ethernet:ti:cpsw: fix phy identification with multiple slaves
> on fixed-phy
> f188b95 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> 0db19b8 net: cpsw: Fix ethernet regression for dm814
> 
> Theses patches don't lead to any issue on the t410 device.

Thanks for verifying. 1873c58, f1eea5, and cdfc0a6d are the previous
patches I referred to.

> Comparing a dmesg output where the driver work: it doesn't show any
> difference from the quoted lines:
> http://paste.fedoraproject.org/304248/45086839/

Thanks for the additional info. I also don't see any red flags in the 
dmesg output. 

When I looked closer at the dm8148-t410 devicetree, I see that it's 
actually more like the BeagleBones than an EVMSK. It specifies two 
slaves, but is not in dual_emac mode. Other than using RGMII mode 
instead of MII, the emac configuration in the DT looks the same to
me. Further, your dmesg shows there is only one actual PHY, same as
a BeagleBone. I assume that's historical, as specifying slaves=<1> 
used to crash (fixed by 1973db0df7c3b in v4.2).

Despite the similarities, I have been unable to reproduce a failure 
on a BeagleBone-Black running linux-next plus this series. Things
that I've checked in dmesg output look similar to yours, so I'm 
currently out of ideas I can check myself. If I could ask you for
some more assistance in debugging:

Are you using the devicetree from the linux-next source, or is it 
modified? If it's modified, can you send it?

Could you check the phy_interface mode used? I know that being wrong
would generate such symptoms. Quickest way to check that (and related
bits) is probably:
   grep -H . /sys/bus/mdio_bus/devices/*/phy*
Based on the devicetree in the kernel source and your dmesg output, 
I expect there to be a single PHY with phy_interface=rgmii and
phy_id=0x4dd074. If any of those aspects don't match what sysfs 
reports, then that's likely to be the cause.

Failing that, I would next try to apply the 3 patches in this series
one at a time (or bisect them) to identify the specific culprit. 

Thanks.
