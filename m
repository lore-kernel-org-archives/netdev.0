From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Sat, 17 Oct 2015 09:21:25 -0500
Message-ID: <alpine.DEB.2.02.1510170920160.12375@linux-builds1>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch> <alpine.DEB.2.02.1510161749490.25648@linux-builds1> <20151016235042.GA28795@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0092.outbound.protection.outlook.com ([207.46.100.92]:27259
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752788AbbJQO2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 10:28:32 -0400
In-Reply-To: <20151016235042.GA28795@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Oct 2015, Andrew Lunn wrote:

> On Fri, Oct 16, 2015 at 05:58:41PM -0500, Dinh Nguyen wrote:
> > On Fri, 16 Oct 2015, Andrew Lunn wrote:
> > 
> > > Commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
> > > the bus' parent." broke finding PHY properties in the MAC device tree
> > > node. The parent device is now the MDIO bus, not the MAC. Use
> > > attached_dev towards the MAC device tree node.
> > > 
> > > Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
> > > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > > ---
> > > 
> > > Compile tested only.
> > > 
> > > Dinh, please could you test it and report back if it works or not.
> > >
> > 
> > This patch did not seem to fix the problem. The following code did seem to
> > fix the problem:
> > 
> > 	if (!of_node && dev->parent->of_node)
> > -               of_node = dev->parent->of_node;
> > +       do {
> > +               of_node = dev->of_node;
> > +               dev = dev->parent;
> > +               i++;
> > +       } while (!of_node && dev);
> 
> This might fix the issue, but it has disadvantages. As i said before,
> it allows people to place phy properties into the mdio device node. We
> want to be reducing placing you can add phy properties, not adding
> more.
> 
> Please could you try to debug why my patch did not work. Is
> attached_dev null?
>

Sure, will try to debug. It looks like phydev->attached_dev is valid, but
phydev->attached_dev->dev.of_node is NULL.
 

BR,
Dinh
