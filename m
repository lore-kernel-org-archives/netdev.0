From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 01/20] net: dsa: mv88e6xxx: factorize PHY
 access with PPU
Date: Fri, 6 May 2016 01:06:59 +0200
Message-ID: <20160505230659.GI7972@lunn.ch>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462488064-1841-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462488064-1841-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>  	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
> -	int ret;
> +	int err;
>  
>  	if (addr < 0)
>  		return 0xffff;
>  
> +

We don't want an extra blank line. I'm surprised checkpatch did not
warn about this.

>  	mutex_lock(&ps->smi_mutex);
> -	ret = _mv88e6xxx_phy_write(ps, addr, regnum, val);
> +
> +	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
> +		err = _mv88e6xxx_phy_write_ppu(ps, addr, regnum, val);
> +	else
> +		err = _mv88e6xxx_phy_write(ps, addr, regnum, val);
> +
>  	mutex_unlock(&ps->smi_mutex);
> -	return ret;
> +
> +	return err;

Please don't rename ret to err. This patch is about phy reading and
writing, and i don't expect to see anything else here. It makes it
harder to review.

	 Andrew
