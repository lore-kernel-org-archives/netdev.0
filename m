From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Sun, 18 Oct 2015 00:54:07 -0500
Message-ID: <alpine.DEB.2.02.1510180049590.20377@linux-builds1>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch> <alpine.DEB.2.02.1510161749490.25648@linux-builds1> <20151016235042.GA28795@lunn.ch> <alpine.DEB.2.02.1510170920160.12375@linux-builds1> <20151017204558.GA8727@lunn.ch>
 <alpine.DEB.2.02.1510172314290.20377@linux-builds1>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0090.outbound.protection.outlook.com ([157.56.111.90]:47040
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751872AbbJRGBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Oct 2015 02:01:08 -0400
In-Reply-To: <alpine.DEB.2.02.1510172314290.20377@linux-builds1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Oct 2015, Dinh Nguyen wrote:

> On Sat, 17 Oct 2015, Andrew Lunn wrote:
> 
> > > Sure, will try to debug. It looks like phydev->attached_dev is valid, but
> > > phydev->attached_dev->dev.of_node is NULL.
> > 
> > Humm
> > 
> > phydev->attached_dev is a net_device, so should be the mac.  What
> > device is phydev->attached_dev->dev? Is it not the dev embedded in the
> > platform_device passed to socfpga_dwmac_probe()?
> >
> 
> Yes, it looks like it is, the dev->of_node is valid in socfpga_dwmac_probe(),
> but it looks like of_node is getting lost somewhere. 
> 

Do you know why this happening? In ksz9021_config_init():

@@ -345,7 +345,11 @@ static int ksz9021_config_init(struct phy_device *phydev)
            phydev->attached_dev->dev.of_node)
                of_node = phydev->attached_dev->dev.of_node;

+	printk("%s %08x\n", __func__, phydev->attached_dev->dev.of_node);
+       printk("%s %08x %08x\n", __func__, phydev->attached_dev->dev, phydev->attached_dev->dev.of_node);


[    1.923311] ksz9021_config_init 00000000
[    1.927224] ksz9021_config_init eedc0210 ee401680

The first printout shows phydev->attached_dev->dev.of_node is NULL. but the
second printout, where I'm also printing out phydev->attached_dev->dev, then
phydev->attached_dev->dev.of_node is not NULL.

BR,
Dinh
