From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 04/11] net: dsa: mv88e6xxx: Abstract stats_snapshot into ops structure
Date: Mon, 14 Nov 2016 10:37:36 +1100
Message-ID: <87a8d3gddr.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch> <1478832823-31471-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36246 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752814AbcKMXhp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 18:37:45 -0500
In-Reply-To: <1478832823-31471-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> +static int mv88e6320_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
> +{
> +	port = (port + 1) << 5;
> +
> +	return _mv88e6xxx_stats_snapshot(chip, port);
> +}

Please move the above helper in its internal SMI file (port, global1 or
whatever) and keep the below wrapper in chip.c. The correct prefix will
avoid having a _ prefix.

> +static int mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
> +{
> +	if (!chip->info->ops->stats_snapshot)
> +		return -EOPNOTSUPP;
> +
> +	return chip->info->ops->stats_snapshot(chip, port);
> +}

[...]

>  static const struct mv88e6xxx_ops mv88e6175_ops = {
> @@ -3223,6 +3243,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
>  	.port_set_duplex = mv88e6xxx_port_set_duplex,
>  	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
>  	.port_set_speed = mv88e6185_port_set_speed,
> +	.stats_snapshot = mv88e6xxx_stats_snapshot,
>  };

Is this expected? Doesn't look correct to me to use
mv88e6xxx_stats_snapshot here.

Thanks,

        Vivien
