From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 01/18] net: dsa: mv88e6xxx: add max VID to info
Date: Wed, 26 Apr 2017 18:04:19 +0200
Message-ID: <20170426160419.GB4489@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42172 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751736AbdDZQEY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 12:04:24 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-2-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:19AM -0400, Vivien Didelot wrote:
> Some chips don't have a VLAN Table Unit, most of them do have a 4K
> table, some others as the 88E6390 family has a 13th bit for the VID.
> 
> Add a new max_vid member to the info structure, used to check the
> presence of a VTU as well as the value used to iterate from in VTU
> GetNext operations.
> 
> This makes the MV88E6XXX_FLAG_VTU obsolete, thus remove it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c      | 38 ++++++++++++++++++++++++++---------
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 13 ++----------
>  2 files changed, 31 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 44ba8cff5631..e45ddf3e90e8 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -1440,7 +1440,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
>  	u16 pvid;
>  	int err;
>  
> -	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
> +	if (!chip->info->max_vid)
>  		return -EOPNOTSUPP;
>  
>  	mutex_lock(&chip->reg_lock);
> @@ -1478,7 +1478,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
>  		err = cb(&vlan->obj);
>  		if (err)
>  			break;
> -	} while (next.vid < GLOBAL_VTU_VID_MASK);
> +	} while (next.vid < chip->info->max_vid);

This change in itself is worth it. We should not be using a mask for
this sort of comparison.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
