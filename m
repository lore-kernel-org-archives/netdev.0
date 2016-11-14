From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 03/11] net: dsa: mv88e6xxx: Add the mv88e6390 family
Date: Mon, 14 Nov 2016 13:05:50 +1100
Message-ID: <8760nqbytd.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch> <1478832823-31471-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40306 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754315AbcKNCGD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 21:06:03 -0500
In-Reply-To: <1478832823-31471-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> -- compatible           : Should be one of "marvell,mv88e6085",
> +- compatible	       : Should be one of "marvell,mv88e6085" or
> +			 "marvell,mv88e6390"

Just curious here, mv88e6085 was choosen because it was the smaller
product ID supported. Following that logic, shouldn't mv88e6190 be
choosen here instead of mv88e6390?

> +static const struct mv88e6xxx_ops mv88e6390_ops = {
> +	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
> +	.phy_read = mv88e6xxx_g2_smi_phy_read,
> +	.phy_write = mv88e6xxx_g2_smi_phy_write,
> +	.port_set_link = mv88e6xxx_port_set_link,
> +	.port_set_duplex = mv88e6xxx_port_set_duplex,
> +	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
> +	.port_set_speed = mv88e6390_port_set_speed,
> +};
> +
> +static const struct mv88e6xxx_ops mv88e6390x_ops = {
> +	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
> +	.phy_read = mv88e6xxx_g2_smi_phy_read,
> +	.phy_write = mv88e6xxx_g2_smi_phy_write,
> +	.port_set_link = mv88e6xxx_port_set_link,
> +	.port_set_duplex = mv88e6xxx_port_set_duplex,
> +	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
> +	.port_set_speed = mv88e6390x_port_set_speed,
> +};

Even if it is a bit more verbose, I'd intentionally keep one
mv88e6xxx_ops structure per chip. Using per-family structure is
error-prone and simpler is better here.

Thanks,

        Vivien
