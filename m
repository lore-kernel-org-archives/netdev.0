From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 09/15] net: dsa: Add support for switch EEPROM access
Date: Thu, 30 Oct 2014 22:11:31 +0100
Message-ID: <20141030211131.GB32139@lunn.ch>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
 <1414604707-22407-10-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1414604707-22407-10-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int dsa_slave_get_eeprom_len(struct net_device *dev)
> +{
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct dsa_switch *ds = p->parent;
> +
> +	if (ds->pd->eeprom_len)
> +		return ds->pd->eeprom_len;
> +
> +	if (ds->drv->get_eeprom_len)
> +		return ds->drv->get_eeprom_len(ds);
> +
> +	return 0;
> +}
> +

Hi Guenter

I just started doing some testing with this patchset. A bit late since
David just accepted it, but...

root@dir665:~# ethtool -e lan4
Cannot get EEPROM data: Invalid argument
root@dir665:~# ethtool -e eth0
Cannot get EEPROM data: Operation not supported

There is no eeprom for the hardware i'm testing. Operation not
supported seems like a better error code and Invalid argument, and is
what other network drivers i tried returned.

      Andrew
