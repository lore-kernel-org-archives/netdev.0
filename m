From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 2/3] [POWERPC] fsl_soc: add support for gianfar for fixed-link property
Date: Tue, 27 Nov 2007 16:59:52 +0300
Message-ID: <20071127135952.GA1483@localhost.localdomain>
References: <20071126142906.19642.45540.stgit@localhost.localdomain> <20071126142915.19642.5842.stgit@localhost.localdomain> <1196089448.12625.62.camel@gentoo-jocke.transmode.se> <20071127113935.GA26867@localhost.localdomain> <1196169432.9816.16.camel@gentoo-jocke.transmode.se>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Vitaly Bordug <vitb@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:7018 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750793AbXK0NzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 08:55:00 -0500
Content-Disposition: inline
In-Reply-To: <1196169432.9816.16.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 02:17:11PM +0100, Joakim Tjernlund wrote:
> 
> On Tue, 2007-11-27 at 14:39 +0300, Anton Vorontsov wrote:
> > On Mon, Nov 26, 2007 at 04:04:08PM +0100, Joakim Tjernlund wrote:
> > > On Mon, 2007-11-26 at 17:29 +0300, Vitaly Bordug wrote:
> > > > fixed-link says: register new "Fixed/emulated PHY", i.e. PHY that
> > > > not connected to the real MDIO bus.
> > > > 
> > > > Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> > > > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> > > > 
> > > > ---
> > > > 
> > > >  Documentation/powerpc/booting-without-of.txt |    3 +
> > > >  arch/powerpc/sysdev/fsl_soc.c                |   56 ++++++++++++++++++--------
> > > >  2 files changed, 42 insertions(+), 17 deletions(-)
> > > > 
> > > > 
> > > > diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
> > > > index e9a3cb1..cf25070 100644
> > > > --- a/Documentation/powerpc/booting-without-of.txt
> > > > +++ b/Documentation/powerpc/booting-without-of.txt
> > > > @@ -1254,6 +1254,9 @@ platforms are moved over to use the flattened-device-tree model.
> > > >        services interrupts for this device.
> > > >      - phy-handle : The phandle for the PHY connected to this ethernet
> > > >        controller.
> > > > +    - fixed-link : <a b c> where a is emulated phy id - choose any,
> > > > +      but unique to the all specified fixed-links, b is duplex - 0 half,
> > > > +      1 full, c is link speed - d#10/d#100/d#1000.
> > > 
> > > Good work!
> > > May I suggest adding a "d" to <a b c> where d is flow control - 0 no, 1 yes
> > 
> > Well, I see no reference of the "flow" neither in the include/linux/mii.h
> > nor in the drivers/net/phy/*. :-/ Thus today there is no such register
> > bit we can emulate?..
> 
> Well, as good as I can recall, flow control(pause) is something that the
> PHY negotiates, just like FDX/HDX and should be dealt with in the
> adjust_link callback but not many do currently.
> 
> If you seach for pause in phy_device.c you will find it.

Ah, pause. Sure, we can emulate that.

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
