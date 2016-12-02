From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 2/4] net: dsa: mv88e6xxx: Monitor and Management tables
Date: Fri, 02 Dec 2016 14:32:39 -0500
Message-ID: <87mvgecejs.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch> <1480701779-30633-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52158 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752895AbcLBTeC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 14:34:02 -0500
In-Reply-To: <1480701779-30633-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> @@ -3184,6 +3186,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
>  	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
>  	.stats_get_strings = mv88e6095_stats_get_strings,
>  	.stats_get_stats = mv88e6095_stats_get_stats,
> +	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
> +	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
>  };

I like the implementation in this version better. But please explain me
why you are prefixing these operations with g1_?

The mv88e6xxx_ops structure is agnostic from the implementation. There
is only one way to implement a feature (e.g. setting the switch MAC) in
Marvell switches. So describing the internal location of the said
feature is wrong and brings no value.

But let's imagine we can set the CPU port in some Global 2 registers.
You are going to wrap this in chip.c with something like:

    int mv88e6xxx_set_cpu_port(struct mv88e6xxx_chip *chip, int port)
    {
        if (chip->info->ops->g2_set_cpu_port)
            return chip->info->ops->g2_set_cpu_port(chip, port);
        else if (chip->info->ops->g1_set_cpu_port)
            return chip->info->ops->g1_set_cpu_port(chip, port);
        else
            return -EOPNOTSUPP;
    }

What's the point of this?

Thanks,

        Vivien
