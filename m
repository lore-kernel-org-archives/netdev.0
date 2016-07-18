From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 03/12] net: dsa: mv88e6xxx: extract device
 mapping
Date: Mon, 18 Jul 2016 21:35:58 +0200
Message-ID: <20160718193558.GK31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44949 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbcGRTgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 15:36:00 -0400
Content-Disposition: inline
In-Reply-To: <20160718184628.13103-4-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* Indirect write to single pointer-data register with an Update bit */
> +static int mv88e6xxx_update_write(struct mv88e6xxx_chip *chip,
> +				  int addr, int reg, u16 update)

Hi Vivien

I don't think mv88e6xxx_update_read() makes any sense? Can we just
infer write? Call it mv88e6xxx_update().

> +static int mv88e6xxx_g2_device_mapping_write(struct mv88e6xxx_chip *chip,
> +					     int target, int port)
> +{
> +	u16 val = (target << 8) | (port & 0xf);
> +
> +	return mv88e6xxx_update_write(chip, REG_GLOBAL2, GLOBAL2_DEVICE_MAPPING,
> +				      val);

This would then all be on one line and look a better.

     Andrew
