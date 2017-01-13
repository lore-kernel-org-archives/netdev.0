From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 08/10] net: dsa: Add support for platform data
Date: Fri, 13 Jan 2017 15:11:10 +0100
Message-ID: <20170113141110.GI10203@lunn.ch>
References: <20170112034121.27697-1-f.fainelli@gmail.com>
 <20170112034121.27697-9-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>,
        gregkh@linuxfoundation.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170112034121.27697-9-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
>  {
> +	struct dsa_chip_data *pdata = dev->platform_data;
>  	struct device_node *np = dev->of_node;
>  	struct dsa_switch_tree *dst;
>  	struct device_node *ports;
>  	u32 tree, index;
>  	int i, err;
>  
> -	err = dsa_parse_member_dn(np, &tree, &index);
> -	if (err)
> -		return err;
> +	if (np) {
> +		err = dsa_parse_member_dn(np, &tree, &index);
> +		if (err)
> +			return err;
>  
> -	ports = dsa_get_ports(ds, np);
> -	if (IS_ERR(ports))
> -		return PTR_ERR(ports);
> +		ports = dsa_get_ports(ds, np);
> +		if (IS_ERR(ports))
> +			return PTR_ERR(ports);
>  
> -	err = dsa_parse_ports_dn(ports, ds);
> -	if (err)
> -		return err;
> +		err = dsa_parse_ports_dn(ports, ds);
> +		if (err)
> +			return err;
> +	} else {
> +		err = dsa_parse_member(pdata, &tree, &index);

Hi Florian

Maybe it is hiding, but i don't see anywhere you check that pdata !=
NULL.

At least for x86 platforms, i don't expect we are booting using
platform data like ARM systems used to do. I think it is more likely a
glue module will be loaded. It looks up the MDIO bus and appends a
platform data to an MDIO device. The switch driver then needs to load
and use the platform data. But if things happen in a different order,
it could be the switch driver probes before the glue driver, meaning
pdata is NULL.

Do we even want to return -EPROBE_DEFERED?

      Andrew
