From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 11/12] net: dsa: mv88e6xxx: add an SMI ops
 structure
Date: Wed, 15 Jun 2016 00:04:35 +0200
Message-ID: <20160614220435.GI12832@lunn.ch>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-12-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46240 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbcFNWEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 18:04:38 -0400
Content-Disposition: inline
In-Reply-To: <20160614183153.32327-12-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +struct mv88e6xxx_smi_ops {
> +	int (*read)(struct mii_bus *bus, int sw_addr,
> +		    int addr, int reg, u16 *val);
> +	int (*write)(struct mii_bus *bus, int sw_addr,
> +		     int addr, int reg, u16 val);
> +};
> +

I think this API would be better if it used ps, not bus and sw_addr.

The only problem is the very first read to get the switch ID. I would
add one more layer in between, so that you can call the lowest level
functions without having a ps structure.

	  Andrew
