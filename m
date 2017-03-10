From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 10/14] net: dsa: mv88e6xxx: rework port mode
 setup
Date: Fri, 10 Mar 2017 01:29:28 +0100
Message-ID: <20170310002928.GC22101@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-11-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42781 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750781AbdCJA3b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 19:29:31 -0500
Content-Disposition: inline
In-Reply-To: <20170309233324.18539-11-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien

> +static int mv88e6xxx_set_port_mode_normal(struct mv88e6xxx_chip *chip, int port)
> +{
> +	return mv88e6xxx_set_port_mode(chip, port, MV88E6XXX_FRAME_MODE_NORMAL,
> +				       PORT_CONTROL_EGRESS_UNMODIFIED, 0x9100);

It would be nice to replace this magic number with a #define. How does
the datasheet describe this? 0x9100 is ETH_P_QINQ1. Would that
actually fit?

> +static int mv88e6xxx_setup_port_mode(struct mv88e6xxx_chip *chip, int port)
> +{
> +	if (dsa_is_dsa_port(chip->ds, port))
> +		return mv88e6xxx_set_port_mode_dsa(chip, port);
> +
> +	if (!dsa_is_cpu_port(chip->ds, port))
> +		return mv88e6xxx_set_port_mode_normal(chip, port);

Maybe add a dsa_is_normal_port() helper? It just makes the code even
easier to read.

       Andrew
