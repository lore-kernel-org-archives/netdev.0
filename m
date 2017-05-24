From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 5/5] dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable
Date: Wed, 24 May 2017 10:58:13 -0400
Message-ID: <87tw4ati7u.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1495573486-31827-1-git-send-email-andrew@lunn.ch> <1495573486-31827-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47794 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940398AbdEXPAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 11:00:15 -0400
In-Reply-To: <1495573486-31827-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> +static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port,
> +				 struct phy_device *phydev)
> +{
> +	struct mv88e6xxx_chip *chip = ds->priv;
> +	int err = 0;
> +
> +	mutex_lock(&chip->reg_lock);
> +	if (chip->info->ops->serdes_power)
> +		err = chip->info->ops->serdes_power(chip, port, true);
> +	mutex_unlock(&chip->reg_lock);
> +
> +	return err;
> +}

Please use your new mv88e6xxx_serdes_power() helper here.

> +
> +static void mv88e6xxx_port_disable(struct dsa_switch *ds, int port,
> +				   struct phy_device *phydev)
> +{
> +	struct mv88e6xxx_chip *chip = ds->priv;
> +
> +	mutex_lock(&chip->reg_lock);
> +	if (chip->info->ops->serdes_power)
> +		chip->info->ops->serdes_power(chip, port, false);
> +	mutex_unlock(&chip->reg_lock);
> +}

Idem, please print a message in case of error as well:

        if (mv88e6xxx_serdes_power())
                dev_err(...)


Thanks,

        Vivien
