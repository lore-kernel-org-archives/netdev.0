From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Sat, 17 Oct 2015 10:06:29 -0500
Message-ID: <alpine.DEB.2.02.1510171004080.31606@linux-builds1>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch> <alpine.DEB.2.02.1510161749490.25648@linux-builds1> <20151016235042.GA28795@lunn.ch> <alpine.DEB.2.02.1510170920160.12375@linux-builds1>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0080.outbound.protection.outlook.com ([65.55.169.80]:16269
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752951AbbJQPN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 11:13:27 -0400
In-Reply-To: <alpine.DEB.2.02.1510170920160.12375@linux-builds1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Oct 2015, Dinh Nguyen wrote:

> On Fri, 16 Oct 2015, Andrew Lunn wrote:
> 
> > On Fri, Oct 16, 2015 at 05:58:41PM -0500, Dinh Nguyen wrote:
> > > On Fri, 16 Oct 2015, Andrew Lunn wrote:
> > > 
> > > > Commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
> > > > the bus' parent." broke finding PHY properties in the MAC device tree
> > > > node. The parent device is now the MDIO bus, not the MAC. Use
> > > > attached_dev towards the MAC device tree node.
> > > > 
> > > > Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
> > > > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > > > ---
> > > > 
> > > > Compile tested only.
> > > > 
> > > > Dinh, please could you test it and report back if it works or not.
> > > >
> > > 
> > > This patch did not seem to fix the problem. The following code did seem to
> > > fix the problem:
> > > 
> > > 	if (!of_node && dev->parent->of_node)
> > > -               of_node = dev->parent->of_node;
> > > +       do {
> > > +               of_node = dev->of_node;
> > > +               dev = dev->parent;
> > > +               i++;
> > > +       } while (!of_node && dev);
> > 
> > This might fix the issue, but it has disadvantages. As i said before,
> > it allows people to place phy properties into the mdio device node. We
> > want to be reducing placing you can add phy properties, not adding
> > more.
> >

I've also tried creating a separate phy node in the DTS and have the EMAC
point the PHY with a 'phy = <&phy0>;', but that also didn't seem to work with
your patch.
 
> 
> Sure, will try to debug. It looks like phydev->attached_dev is valid, but
> phydev->attached_dev->dev.of_node is NULL.
>  
> 
> BR,
> Dinh
> 

BR,
Dinh
