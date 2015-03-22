From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 08/18] net: dsa: mv88e6xxx: Add Hardware bridging support
Date: Sun, 22 Mar 2015 21:06:00 +0100
Message-ID: <20150322200600.GD15025@lunn.ch>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
 <1426952815-4642-9-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426952815-4642-9-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guenter

> +static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
> +{
> +	int ret;
> +
> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
> +	if (ret < 0)
> +		return ret;

Please could you check this. I think register 0x01 here is wrong. I
think you want 0x0b, the ATU Operations register?

Thanks
	Andrew

> +
> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x0b, cmd);
> +	if (ret < 0)
> +		return ret;
> +
> +	return _mv88e6xxx_atu_wait(ds);
> +}
> +
