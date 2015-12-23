From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: Re: [PATCH 0/3] drivers: net: cpsw: phy-handle fixes
Date: Wed, 23 Dec 2015 16:54:54 -0500
Message-ID: <20151223165454.6e4d5950.drivshin.allworx@gmail.com>
References: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
	<CABr+WT=oDpp56jouAD57UM8_38geD1MMizZcDnx14maf2ohpCw@mail.gmail.com>
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
Received: from mail-qk0-f170.google.com ([209.85.220.170]:34693 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbLWVy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 16:54:57 -0500
In-Reply-To: <CABr+WT=oDpp56jouAD57UM8_38geD1MMizZcDnx14maf2ohpCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Dec 2015 22:20:58 +0100
Nicolas Chauvet <kwizart@gmail.com> wrote:

> 2015-12-23 1:36 GMT+01:00 David Rivshin (Allworx) <
> drivshin.allworx@gmail.com>:
> 
> > From: David Rivshin <drivshin@allworx.com>
> >
> > This series is based on the tip of the net tree.
> >
> > The first patch fixes a bug that makes dual_emac mode break if
> > either slave uses the phy-handle property in the devicetree.
> >
> > The second patch fixes some cosmetic problems with error messages,
> > and also makes the binding documentation more explicit.
> >
> > The third patch cleans up the fixed-link case to work like
> > the now-fixed phy-handle case.
> >
> > I have tested on the following hardware configurations:
> >  - (EVMSK) dual emac, phy_id property in both slaves
> >  - (BeagleBoneBlack) single emac, phy_id property
> >  - (custom) single emac, fixed-link subnode
> > Note that I don't have a board which would uses a phy-handle
> > property, though I have used hacked devicetrees to exercise the
> > code paths. Testing by anyone who has real hardware using
> > phy-handle or dual_emac with fixed-link would be appreciated.
> >
> > David Rivshin (3):
> >   drivers: net: cpsw: fix parsing of phy-handle DT property in
> > dual_emac config
> >   drivers: net: cpsw: fix error messages when using phy-handle DT
> >     property
> >   drivers: net: cpsw: use of_phy_connect() in fixed-link case
> >
> >  Documentation/devicetree/bindings/net/cpsw.txt |  4 +--
> >  drivers/net/ethernet/ti/cpsw.c                 | 40
> > +++++++++++++-------------
> >  drivers/net/ethernet/ti/cpsw.h                 |  1 +
> >  3 files changed, 23 insertions(+), 22 deletions(-)
> >
> >
> This serie failed with me on dm8418 hp-t410 on top of linux-next from
> today whereas the same patch level and same methods without this
> serie is working fine.
> I wasn't able to ping anything on a minimal rootfs with static ip set
> from cmdline from kernel.
> 
> Sorry for  the lack of details, feel free to add me to any other
> revision of the patch if any.
> I will be able to do more testing next month.

(Sorry for the duplicate, doing a reply-all this time. Not sure why it 
looked like a non-list email the first time)

Thanks for testing. I found the dm8148-t410.dts devicetree in the
kernel source, and it uses the phy_id for both slaves, just like the
EVMSK board I tested. So I can't think of an obvious reason for the
problem. 
Would you be able to send the 'dmesg' log from right after bootup? 
I'm hoping there is an error message in there with some clue.

Just to verify, is your linux-next tree up-to-date? This series needs
to be applied is based on another recent series of 3 patches to cpsw.c. 
Although I doubt it would apply cleanly at all without those.
