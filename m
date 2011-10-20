From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 15/17] phy_device: Add "port" and "transciever"
 fields
Date: Fri, 21 Oct 2011 00:27:59 +0100
Message-ID: <1319153279.2918.16.camel@deadeye>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
	 <1319144425-15547-16-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	David Decotigny <decot@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Mike Frysinger <vapier@gentoo.org>
To: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-16-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-10-20 at 17:00 -0400, Kyle Moffett wrote:
> Some PHYs have multiple software-selectable inputs and outputs,
> including RGMII, SGMII, SerDes, etc.  New fields are added to the
> "struct phy_device" for "port" and "transciever" to allow "ethtool" to
> switch outputs at runtime.  The defaults for the new fields are
> identical to the hardcoded values used previously.
> 
> This should make no functional changes to the PHY layer behavior, but
> it will allow later PHY/ethernet drivers to override those fields.
> 
> Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
> ---
>  drivers/net/phy/phy.c        |    4 ++--
>  drivers/net/phy/phy_device.c |    2 ++
>  include/linux/phy.h          |    4 ++++
>  3 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index c378f91..5f72055 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -290,9 +290,9 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
>  
>  	ethtool_cmd_speed_set(cmd, phydev->speed);
>  	cmd->duplex = phydev->duplex;
> -	cmd->port = PORT_MII;
> +	cmd->port = phydev->port;
>  	cmd->phy_address = phydev->addr;
> -	cmd->transceiver = XCVR_EXTERNAL;
> +	cmd->transceiver = phydev->transciever;

'transceiver' is spelt thus.

[...]
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -308,6 +308,10 @@ struct phy_device {
>  	u32 supported;
>  	u32 advertising;
>  
> +	/* The current port/xcvr info (Copper, Fibre, MII, Direct-Attach) */
> +	u8 port;
> +	u8 transceiver;
> +

And yet you got it right here.

Ben.

>  	int autoneg;
>  
>  	int link_timeout;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
