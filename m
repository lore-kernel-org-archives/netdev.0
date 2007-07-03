From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] ucc_geth.c, make PHY device optional.
Date: Tue, 03 Jul 2007 09:20:46 +0200
Message-ID: <1183447246.20673.155.camel@gentoo-jocke.transmode.se>
References: <989B956029373F45A0B8AF0297081890D837CB@zch01exm26.fsl.freescale.net>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev Development <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>,
	Fleming Andy-afleming <afleming@freescale.com>
To: Li Yang-r58472 <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:53614 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755422AbXGCHUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 03:20:51 -0400
In-Reply-To: <989B956029373F45A0B8AF0297081890D837CB@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-03 at 11:42 +0800, Li Yang-r58472 wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org
> [mailto:netdev-owner@vger.kernel.org] On
> > Behalf Of Joakim Tjernlund
> > Sent: Tuesday, July 03, 2007 8:52 AM
> > To: 'linuxppc-dev Development'; 'Netdev'; Li Yang-r58472
> > Subject: [PATCH] ucc_geth.c, make PHY device optional.
> > 
> > > This patch makes the PHY optional for ucc_geth.c ethernet driver.
> > > This is useful to support a direct mii to mii connection to, for
> example,
> > > a onboard swicth.
> > >
> > > Signed-off-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> > ----
> Hi Joakim,
> 
> I'm wondering if we really need to have the option to disable phylib.

maybe, but it has to be dynamic too. I need to use PHY on UCC2 and mii
on UCC3 and UCC4.

> Actually we have made phylib selected by default for ucc_geth.  Many L2
> switch chips have the capacity to be controlled.  Therefore they can be
> managed as a phy device.

Yes, they can be but why force a PHY impl. when its is of no use? The
only thing the eth driver needs from the it is speed and duplex. If
these are fixed, you don't need to talk with a PHY.

> For the MII interface which is not
> configurable, shouldn't we use the fixed phy support from Vitaly?

Well, I think the the fixed phy is great when your eth driver requires a
PHY, but it is a workaround with extra processing overhead. IMHO the
best impl. is to make the PHY optional in the eth driver and as you can
see from the patch, that was really simple.

An useful extension would be to add a new propety in the DTS to hold
initial speed and duplex(perhaps extend phy-connection-type). This
would be useful for the fixed driver too as one could derive speed and
duplex for the fixed phy from that property instead of creating a fixed
phy for each speed and duplex one want to support.

 Jocke
