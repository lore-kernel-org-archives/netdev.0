From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC 16/28] dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
Date: Thu, 21 Jan 2016 15:54:51 -0500
Message-ID: <871t9a4pr8.fsf@ketchup.mtl.sfl>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch> <1450875402-20740-17-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	narmstrong@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53242 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbcAUUzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 15:55:04 -0500
In-Reply-To: <1450875402-20740-17-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> mv88e6xxx_lookup_name() returns the model name of a switch at a given
> address on an MII bus. Using mii_bus it identify the bus rather than
> the host device is more logical, so change the parameter.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/dsa/mv88e6123.c | 4 +++-
>  drivers/net/dsa/mv88e6131.c | 4 +++-
>  drivers/net/dsa/mv88e6171.c | 4 +++-
>  drivers/net/dsa/mv88e6352.c | 4 +++-
>  drivers/net/dsa/mv88e6xxx.c | 9 +++------
>  drivers/net/dsa/mv88e6xxx.h | 2 +-
>  6 files changed, 16 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
> index 6d6fca62e8b1..2c23762cbed8 100644
> --- a/drivers/net/dsa/mv88e6123.c
> +++ b/drivers/net/dsa/mv88e6123.c
> @@ -31,7 +31,9 @@ static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
>  
>  static char *mv88e6123_drv_probe(struct device *host_dev, int sw_addr)
>  {
> -	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6123_table,
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
> +
> +	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6123_table,
>  				     ARRAY_SIZE(mv88e6123_table));
>  }
>  
> diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
> index e0aa3be7f5a9..02d2bca095af 100644
> --- a/drivers/net/dsa/mv88e6131.c
> +++ b/drivers/net/dsa/mv88e6131.c
> @@ -27,7 +27,9 @@ static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
>  
>  static char *mv88e6131_drv_probe(struct device *host_dev, int sw_addr)
>  {
> -	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6131_table,
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
> +
> +	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6131_table,
>  				     ARRAY_SIZE(mv88e6131_table));
>  }
>  
> diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
> index 8fc4db23744e..d557be12feb7 100644
> --- a/drivers/net/dsa/mv88e6171.c
> +++ b/drivers/net/dsa/mv88e6171.c
> @@ -26,7 +26,9 @@ static const struct mv88e6xxx_switch_id mv88e6171_table[] = {
>  
>  static char *mv88e6171_drv_probe(struct device *host_dev, int sw_addr)
>  {
> -	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6171_table,
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
> +
> +	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6171_table,
>  				     ARRAY_SIZE(mv88e6171_table));
>  }
>  
> diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
> index 2877ad8acefa..959835d69af6 100644
> --- a/drivers/net/dsa/mv88e6352.c
> +++ b/drivers/net/dsa/mv88e6352.c
> @@ -38,7 +38,9 @@ static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
>  
>  static char *mv88e6352_drv_probe(struct device *host_dev, int sw_addr)
>  {
> -	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6352_table,
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
> +
> +	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6352_table,
>  				     ARRAY_SIZE(mv88e6352_table));
>  }
>  
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 170b98f3acbe..23b0ff9f0154 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -2606,16 +2606,12 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
>  }
>  #endif /* CONFIG_NET_DSA_HWMON */
>  
> -char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
> +char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
>  			    const struct mv88e6xxx_switch_id *table,
>  			    unsigned int num)
>  {
> -	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
>  	int i, ret;
>  
> -	if (!bus)
> -		return NULL;
> -
>  	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
>  	if (ret < 0)
>  		return NULL;

The check for !bus is removed and thus the underlying calls to
mdiobus_read_nested can segfault.

> @@ -2628,7 +2624,8 @@ char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
>  	/* Look up only the product number */
>  	for (i = 0; i < num; ++i) {
>  		if (table[i].id == (ret & PORT_SWITCH_ID_PROD_NUM_MASK)) {
> -			dev_warn(host_dev, "unknown revision %d, using base switch 0x%x\n",
> +			dev_warn(&bus->dev,
> +				 "unknown revision %d, using base switch 0x%x\n",

Does checkpatch complains about that? I thought it was OK to have
strings exceeding 80 chars.

>  				 ret & PORT_SWITCH_ID_REV_MASK,
>  				 ret & PORT_SWITCH_ID_PROD_NUM_MASK);
>  			return table[i].name;
> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
> index 62069b30f6e5..441aec066294 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -436,7 +436,7 @@ struct mv88e6xxx_hw_stat {
>  };
>  
>  int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
> -char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
> +char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
>  			    const struct mv88e6xxx_switch_id *table,
>  			    unsigned int num);
>  int mv88e6xxx_setup_ports(struct dsa_switch *ds);
> -- 
> 2.6.3

Thanks,
-v
