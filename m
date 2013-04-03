From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netdev/phy: Implement ieee802.3 clause 45 in
 mdio-octeon.c
Date: Wed, 3 Apr 2013 20:08:57 +0100
Message-ID: <1365016137.2897.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <1365013008-10914-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	David Daney <david.daney@cavium.com>
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365013008-10914-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-04-03 at 11:16 -0700, David Daney wrote:
> From: David Daney <david.daney@cavium.com>
> 
> The Octeon SMI/MDIO interfaces can do clause 45 communications, so
> implement this in the driver.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>  drivers/net/phy/mdio-octeon.c | 89 +++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 86 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
> index c2c878d..f4f3abf 100644
> --- a/drivers/net/phy/mdio-octeon.c
> +++ b/drivers/net/phy/mdio-octeon.c
[...]
>  static int octeon_mdiobus_read(struct mii_bus *bus, int phy_id, int regnum)
>  {
>  	struct octeon_mdiobus *p = bus->priv;
>  	union cvmx_smix_cmd smi_cmd;
>  	union cvmx_smix_rd_dat smi_rd;
> +	unsigned int op = 1; /* MDIO_CLAUSE_22_READ */
>  	int timeout = 1000;
>  
> +	if (regnum & MII_ADDR_C45) {
> +		int r = octeon_mdiobus_c45_addr(p, phy_id, regnum);
> +		if (r < 0)
> +			return r;
> +
> +		regnum = (regnum >> 16) & 0x1f;
> +		op = 3; /* MDIO_CLAUSE_45_READ */
> +	} else {
> +		octeon_mdiobus_set_mode(p, C22);
> +	}
> +
> +
>  	smi_cmd.u64 = 0;
> -	smi_cmd.s.phy_op = 1; /* MDIO_CLAUSE_22_READ */
> +	smi_cmd.s.phy_op = op; /* MDIO_CLAUSE_22_READ */
[...]

This comment should now be removed.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
