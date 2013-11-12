From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [PATCH 1/4] phylib: Add Clause 45 read/write functions
Date: Tue, 12 Nov 2013 12:30:48 +0000
Message-ID: <ED492CCEAF882048BC2237DE806547C915117378@039-SN2MPN1-013.039d.mgd.msft.net>
References: <1384167864-2457-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jg1.han@samsung.com" <jg1.han@samsung.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"michal.simek@xilinx.com" <michal.simek@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "shh.xie@gmail.com" <shh.xie@gmail.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384167864-2457-1-git-send-email-shh.xie@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added more people and list.

Best Regards, 
Shaohui Xie


> -----Original Message-----
> From: shh.xie@gmail.com [mailto:shh.xie@gmail.com]
> Sent: Monday, November 11, 2013 7:04 PM
> To: linuxppc-dev@lists.ozlabs.org; linux-kernel@vger.kernel.org
> Cc: Bucur Madalin-Cristian-B32716; Kanetkar Shruti-B44454; Xie Shaohui-B21989
> Subject: [PATCH 1/4] phylib: Add Clause 45 read/write functions
> 
> From: Andy Fleming
> 
> You need an extra parameter to read or write Clause 45 PHYs, so we need a
> different API with the extra parameter.
> 
> Signed-off-by: Andy Fleming
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
>  include/linux/phy.h | 33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
> 
> diff --git a/include/linux/phy.h b/include/linux/phy.h index 64ab823..684925a
> 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -498,6 +498,21 @@ static inline int phy_read(struct phy_device *phydev, u32
> regnum)  }
> 
>  /**
> + * phy_read_mmd - Convenience function for reading a register
> + *   from an MMD on a given PHY.
> + * @phydev: The phy_device struct
> + * @devad: The MMD to read from
> + * @regnum: The register on the MMD to read
> + *
> + * Same rules as for phy_read();
> + */
> +static inline int phy_read_mmd(struct phy_device *phydev, int devad,
> +u32 regnum) {
> +	return mdiobus_read(phydev->bus, phydev->addr,
> +		MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff)); }
> +
> +/**
>   * phy_write - Convenience function for writing a given PHY register
>   * @phydev: the phy_device struct
>   * @regnum: register number to write
> @@ -533,6 +548,24 @@ static inline bool phy_is_internal(struct phy_device
> *phydev)
>  	return phydev->is_internal;
>  }
> 
> +/**
> + * phy_write_mmd - Convenience function for writing a register
> + *   on an MMD on a given PHY.
> + * @phydev: The phy_device struct
> + * @devad: The MMD to read from
> + * @regnum: The register on the MMD to read
> + * @val: value to write to @regnum
> + *
> + * Same rules as for phy_write();
> + */
> +static inline int phy_write_mmd(struct phy_device *phydev, int devad,
> +		u32 regnum, u16 val)
> +{
> +	regnum = MII_ADDR_C45 | ((devad & 0x1f) << 16) | (regnum & 0xffff);
> +
> +	return mdiobus_write(phydev->bus, phydev->addr, regnum, val); }
> +
>  struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
>  		bool is_c45, struct phy_c45_device_ids *c45_ids);  struct
> phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45);
> --
> 1.8.4.1
