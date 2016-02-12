From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Revert "net: phy: turn carrier off on phy attach"
Date: Fri, 12 Feb 2016 10:56:04 -0800
Message-ID: <56BE2AC4.2040908@gmail.com>
References: <1455300113-2335-1-git-send-email-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Clemens Gruber <clemens.gruber@pqgruber.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455300113-2335-1-git-send-email-clemens.gruber@pqgruber.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/16 10:01, Clemens Gruber wrote:
> Commit 113c74d83eef ("net: phy: turn carrier off on phy attach") breaks
> the eth0 link coming up on all my i.MX6Q boards with a Marvell 88E1510.
> If I then do a ifconfig eth0 down/up cycle I first get a MDIO read
> timeout but then the link becomes ready and everything is back to
> normal.
> Without this step however, the link stays down forever, an unusually
> high amount of phy interrupts occur (about 10000/second) and kworker/0:2
> is constantly using over 60% of the CPU.
> 
> Reverting it fixes the problems with the link not coming up at boot as
> well as the high amount of phy interrupts and kworker load in that
> state.

You are seeing this with the FEC driver right? We probably want to
carefully audit the driver and understand what could be going wrong, the
initial change is correct, so there must be something else going on here.

> 
> This reverts commit 113c74d83eef870e43a0d9279044e9d5435f0d07.
> 
> Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
> ---
>  drivers/net/phy/phy_device.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index bad3f00..903737a 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -901,11 +901,6 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  
>  	phydev->state = PHY_READY;
>  
> -	/* Initial carrier state is off as the phy is about to be
> -	 * (re)initialized.
> -	 */
> -	netif_carrier_off(phydev->attached_dev);
> -
>  	/* Do initial configuration here, now that
>  	 * we have certain key parameters
>  	 * (dev_flags and interface)
> 


-- 
Florian
