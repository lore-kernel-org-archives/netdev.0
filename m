From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 07/18] net: dsa: mv88e6xxx: move VTU VID
 accessors
Date: Thu, 27 Apr 2017 20:51:34 +0200
Message-ID: <20170427185134.GJ17364@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-8-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -1464,13 +1457,16 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
>  				    struct mv88e6xxx_vtu_entry *entry)
>  {
>  	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
> -	u16 reg = 0;
>  	int err;
>  
>  	err = mv88e6xxx_g1_vtu_op_wait(chip);
>  	if (err)
>  		return err;
>  
> +	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
> +	if (err)
> +		return err;
> +
>  	if (!entry->valid)
>  		goto loadpurge;
>  
> @@ -1496,14 +1492,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
>  		op |= (entry->fid & 0xf0) << 8;
>  		op |= entry->fid & 0xf;
>  	}
> -
> -	reg = GLOBAL_VTU_VID_VALID;
>  loadpurge:
> -	reg |= entry->vid & GLOBAL_VTU_VID_MASK;
> -	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, reg);
> -	if (err)
> -		return err;
> -
>  	return mv88e6xxx_g1_vtu_op(chip, op);
>  }

This is not obvious, why do the vtu_vid_write() at the beginning,
rather than at the end? Especially before the if (!entry->valid).

However, when you look at the rest of the patch, it is O.K.

It might of been better to do this in two patches, to make it clearer
what is going on.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
