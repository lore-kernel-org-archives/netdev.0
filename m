From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: bcm_sf2: Register our slave
 MDIO bus
Date: Tue, 7 Jun 2016 19:00:50 +0200
Message-ID: <20160607170050.GA28994@lunn.ch>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
 <1465254895-11152-6-git-send-email-f.fainelli@gmail.com>
 <87oa7dxdis.fsf@ketchup.mtl.sfl>
 <87r3c9vtay.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemlof.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34863 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161308AbcFGRAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 13:00:53 -0400
Content-Disposition: inline
In-Reply-To: <87r3c9vtay.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 12:48:37PM -0400, Vivien Didelot wrote:
> Hi Florian, Andrew,
> 
> Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:
> 
> > Hum reviewing that again, I see that if one of the 2 subsequent calls to
> > request_irq fails, you end up with an unregistered MDIO bus.
> >
> > We have the same issue in the mv88e6xxx legacy probe code if dsa.c fails
> > to allocate the dsa_switch structure. I'm moving the MDIO register code
> > to the setup function like you are doing here (good idea!) to fix that.
> 
> In fact it doesn't fix the issue because dsa_switch_driver doesn't
> provide any remove/teardown function, in which mv88e6xxx and sf2 could
> unregister their MDIO bus on switch removal.
> 
> Would it be worth it to add such optional function to DSA drivers?

It is not needed with DSA2 binding. The driver is always in control,
and it performs the unregister from the core. So it knows when to
unregister the mdio bus, either because probe has failed for some
reason, or it is being unloaded. That is also why i register the mdio
bus in probe, and unregister it in remove. Normal practice for a
driver.

With the legacy interface it is tricky. When would you call such a
remove/tairdown function when using the old binding?

	Andrew
