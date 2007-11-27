From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 2/3] [POWERPC] fsl_soc: add support for gianfar for fixed-link property
Date: Tue, 27 Nov 2007 14:39:35 +0300
Message-ID: <20071127113935.GA26867@localhost.localdomain>
References: <20071126142906.19642.45540.stgit@localhost.localdomain> <20071126142915.19642.5842.stgit@localhost.localdomain> <1196089448.12625.62.camel@gentoo-jocke.transmode.se>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Vitaly Bordug <vitb@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:6558 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753656AbXK0Lem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 06:34:42 -0500
Content-Disposition: inline
In-Reply-To: <1196089448.12625.62.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 04:04:08PM +0100, Joakim Tjernlund wrote:
> On Mon, 2007-11-26 at 17:29 +0300, Vitaly Bordug wrote:
> > fixed-link says: register new "Fixed/emulated PHY", i.e. PHY that
> > not connected to the real MDIO bus.
> > 
> > Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> > 
> > ---
> > 
> >  Documentation/powerpc/booting-without-of.txt |    3 +
> >  arch/powerpc/sysdev/fsl_soc.c                |   56 ++++++++++++++++++--------
> >  2 files changed, 42 insertions(+), 17 deletions(-)
> > 
> > 
> > diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
> > index e9a3cb1..cf25070 100644
> > --- a/Documentation/powerpc/booting-without-of.txt
> > +++ b/Documentation/powerpc/booting-without-of.txt
> > @@ -1254,6 +1254,9 @@ platforms are moved over to use the flattened-device-tree model.
> >        services interrupts for this device.
> >      - phy-handle : The phandle for the PHY connected to this ethernet
> >        controller.
> > +    - fixed-link : <a b c> where a is emulated phy id - choose any,
> > +      but unique to the all specified fixed-links, b is duplex - 0 half,
> > +      1 full, c is link speed - d#10/d#100/d#1000.
> 
> Good work!
> May I suggest adding a "d" to <a b c> where d is flow control - 0 no, 1 yes

Well, I see no reference of the "flow" neither in the include/linux/mii.h
nor in the drivers/net/phy/*. :-/ Thus today there is no such register
bit we can emulate?..

> flow control or not just popped up here today so I got a use for it.

..and I looked into few drivers (gianfar, ucc), and they seem to use
hard-coded flow control values, thus they don't speak to the PHYs
about that.

Can you give any reference to the driver that needs that parameter?
Does it use PHY subsystem to obtain flow-control on/off information?

Thanks,

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
