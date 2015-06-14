From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: Ensure clocks are enabled while using mdio bus
Date: Sun, 14 Jun 2015 16:41:18 +0200
Message-ID: <20150614144118.GA7800@lunn.ch>
References: <1434123545-13549-1-git-send-email-andrew@lunn.ch>
 <BLUPR03MB373E1D5EADCB4753C8D0F15F5B90@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Duan Andy <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55793 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524AbbFNOrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Jun 2015 10:47:05 -0400
Content-Disposition: inline
In-Reply-To: <BLUPR03MB373E1D5EADCB4753C8D0F15F5B90@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 14, 2015 at 08:07:12AM +0000, Duan Andy wrote:
> From: Andrew Lunn <andrew@lunn.ch> Sent: Friday, June 12, 2015 11:39 PM
> > To: David Miller
> > Cc: Duan Fugang-B38611; Cory Tusar; netdev; Andrew Lunn
> > Subject: [PATCH] net: fec: Ensure clocks are enabled while using mdio bus
> > 
> > When a switch is attached to the mdio bus, the mdio bus can be used while
> > the interface is not open. If the clocks are not enabled, MDIO
> > reads/writes will simply time out. So enable the clocks before starting a
> > transaction, and disable them afterwards. The CCF performs reference
> > counting so the clocks will only be disabled if there are no other users.
> > 
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > ---
> 
> NAK the patch.

> i.MX series MDIO bus is a part of ENET controller. If the eth
> interface is not open, all clocks including MDIO bus clock are not
> enabled for power saving.

Where do you see a power saving regression in this code? It is not as
if i just unconditionally turn the clocks on. As the comment says, at
the start of an MDIO transaction, the clocks are enabled. At the end
of a transaction, they are disabled again. If you don't have a switch
connected, there will be no transactions, hence no change to power
savings.

> In general, if you want to use mdio bus net interface must be
> running status.

This is not true for a number of Ethernet devices. All those currently
used with DSA allow MDIO transactions at any time.

     Andrew
