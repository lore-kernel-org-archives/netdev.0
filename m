From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: handle multiple ports in
 ATU
Date: Tue, 20 Sep 2016 02:19:14 +0200
Message-ID: <20160920001914.GB6323@lunn.ch>
References: <20160919235611.31975-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160919235611.31975-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien

> +	do {
> +		err = _mv88e6xxx_atu_getnext(chip, fid, &next);
> +		if (err)
> +			return err;
> +
> +		if (next.state == GLOBAL_ATU_DATA_STATE_UNUSED)
> +			break;
> +
> +		if (ether_addr_equal(next.mac, addr)) {
> +			*entry = next;
> +			return 0;
> +		}
> +	} while (!is_broadcast_ether_addr(next.mac));

This is correct, but i wonder how well it scales? When we have a lot
of entries in the ATU, this is going to take time. At some point in
the future, we might want to keep a shadow copy of static entries of
the ATU in RAM. We then don't need to search for them.

But that is for later, once we have some complaints this is too slow.

    Andrew
