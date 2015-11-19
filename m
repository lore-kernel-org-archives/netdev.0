From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phylib: Make PHYs children of their MDIO bus, not the
 bus' parent.
Date: Thu, 19 Nov 2015 22:06:51 +0100
Message-ID: <20151119210651.GA5044@lunn.ch>
References: <1440198963-20080-1-git-send-email-ddaney.cavm@gmail.com>
 <564E3659.1040709@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney.cavm@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <david.daney@cavium.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Grant Likely <grant.likely@secretlab.ca>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <564E3659.1040709@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 19, 2015 at 11:51:37PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 08/22/2015 02:16 AM, David Daney wrote:
> 
> >From: David Daney <david.daney@cavium.com>
> >
> >commit 18ee49ddb0d2 ("phylib: rename mii_bus::dev to mii_bus::parent")
> >changed the parent of PHY devices from the bus to the bus parent.
> >
> >Then, commit 4dea547fef1b ("phylib: rework to prepare for OF
> >registration of PHYs") moved the code into phy_device.c
> >
> >At this point, it is somewhat unclear why the change was seen as
> >necessary.  But, when we look at the device model tree in
> >/sys/devices, it is clearly incorrect.  The PHYs should be children of
> >their MDIO bus.
> >
> >Change the PHY's parent device to be the MDIO bus device.
> >
> >Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> >Cc: Grant Likely <grant.likely@secretlab.ca>
> >Signed-off-by: David Daney <david.daney@cavium.com>
> >---
> >  drivers/net/phy/phy_device.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> >index 0302483..55f0178 100644
> >--- a/drivers/net/phy/phy_device.c
> >+++ b/drivers/net/phy/phy_device.c
> >@@ -176,7 +176,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
> >  	if (c45_ids)
> >  		dev->c45_ids = *c45_ids;
> >  	dev->bus = bus;
> >-	dev->dev.parent = bus->parent;
> >+	dev->dev.parent = &bus->dev;
> >  	dev->dev.bus = &mdio_bus_type;
> >  	dev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
> >  	dev_set_name(&dev->dev, PHY_ID_FMT, bus->id, addr);
> 
>    This patch makes my sh_eth driver fail to connect to PHY usinjg
> of_phy_connect(). (The ravb driver fails too but for some other
> reason.)
 
Hi Sergei

What phy is it?

Do you have phy DT properties in the MAC node?

   Andrew
