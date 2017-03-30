From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/9] net: dsa: mv88e6xxx: program the PVT with
 all ones
Date: Thu, 30 Mar 2017 15:45:21 +0200
Message-ID: <20170330134521.GC17879@lunn.ch>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
 <20170329203020.27042-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40538 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750766AbdC3NpY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 09:45:24 -0400
Content-Disposition: inline
In-Reply-To: <20170329203020.27042-4-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	for (dev = 0; dev < 32; ++dev) {
> +		for (port = 0; port < 16; ++port) {
> +			err = mv88e6xxx_pvt_map(chip, dev, port);
> +			if (err)
> +				return err;
> +		}
> +	}
> +
> +	return 0;

Hi Vivien

How about adding MV88E6XXX_MAX_PVT_SWITCHES and MV88E6XXX_MAX_PVT_PORTS?


> +static int mv88e6xxx_g2_pvt_op(struct mv88e6xxx_chip *chip, int src_dev,
> +			       int src_port, u16 op)
> +{
> +	int err;
> +
> +	/* 9-bit Cross-chip PVT pointer: with GLOBAL2_MISC_5_BIT_PORT cleared,
> +	 * source device is 5-bit, source port is 4-bit.
> +	 */
> +	op |= (src_dev & 0x1f) << 4;
> +	op |= (src_port & 0xf);

So here, are you hard coding the knowledge that we passed false to
mv88e6xxx_g2_misc_5_bit_port()?  It kind of defeats the point of
having the parameter. Maybe simplify the code and remove the
parameter?

	Andrew
