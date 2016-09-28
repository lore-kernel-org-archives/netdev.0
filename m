From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 2/6] net: phy: Use threaded IRQ, to allow IRQ from
 sleeping devices
Date: Wed, 28 Sep 2016 14:24:56 +0200
Message-ID: <20160928122456.GA22809@lunn.ch>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-3-git-send-email-andrew@lunn.ch>
 <b93c08b9-1ed0-19d4-bd77-53a4958da97e@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35093 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932211AbcI1MY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 08:24:59 -0400
Content-Disposition: inline
In-Reply-To: <b93c08b9-1ed0-19d4-bd77-53a4958da97e@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 02:38:03PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 9/28/2016 11:32 AM, Andrew Lunn wrote:
> 
> >The interrupt lines from PHYs maybe connected to I2C bus expanders, or
> >from switches on MDIO busses. Such interrupts are sourced from devices
> >which sleep, so use threaded interrupts. Threaded interrupts require
> >that the interrupt requester also uses the threaded API. Change the
> >phylib to use the threaded API, which is backwards compatible with
> >none-threaded IRQs.
> >
> >Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> >---
> > drivers/net/phy/phy.c | 7 +++----
> > 1 file changed, 3 insertions(+), 4 deletions(-)
> >
> >diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> >index c6f66832a1a6..5c29ed72f721 100644
> >--- a/drivers/net/phy/phy.c
> >+++ b/drivers/net/phy/phy.c
> >@@ -722,10 +722,9 @@ phy_err:
> > int phy_start_interrupts(struct phy_device *phydev)
> > {
> > 	atomic_set(&phydev->irq_disable, 0);
> >-	if (request_irq(phydev->irq, phy_interrupt,
> >-				IRQF_SHARED,
> >-				"phy_interrupt",
> >-				phydev) < 0) {
> >+	if (request_threaded_irq(phydev->irq, NULL, phy_interrupt,
> >+				 IRQF_ONESHOT, "phy_interrupt",
> 
>    What about IRQF_SHARED?

I will check if you can have a shared oneshot.

  Andrew
