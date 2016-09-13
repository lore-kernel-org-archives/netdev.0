From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 13:11:56 -0400
Message-ID: <87twdjafmr.fsf@ketchup.mtl.sfl>
References: <1473669337-21221-1-git-send-email-john@phrozen.org> <1473669337-21221-4-git-send-email-john@phrozen.org> <20160913012304.GC3585@lunn.ch> <5c028659-db7e-9a98-7ec1-1e2d19d135f9@phrozen.org> <20160913131408.GE15332@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160913131408.GE15332@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> ok, i will simply substract 1 from the phy_addr inside the mdio
>> callbacks. this would make the code more readable and make the DT
>> binding compliant with the ePAPR spec.
>
> It does however need well commenting. It is setting a trap for anybody
> who puts an external PHY on port 6. If they access that PHY via these
> functions, the address is off by one.
>
> This is the first silicon vendor who made their MDIO addresses for
> PHYs illogical. So i'm thinking we maybe should add a new function to
> dsa_switch_ops.
>
> 	/* Return the MDIO address for the PHY for this port. */
>         int     (*phy_port_map(struct dsa_switch *ds, int port);
>
> This should return the MDIO address for integrated PHYs only, or
> -ENODEV if the port does not have an integrated PHY. For an external
> PHY, a phy-handle should be used. This phy_port_map() is used in
> dsa_slave_phy_setup(). But dsa_slave_phy_setup() is already too
> complex, so it needs doing with care.

Note that some switch drivers *have to* register their slave MDIO bus
themselves (e.g. bcm_sf2). This becomes confusing with the DSA
phy_{read,write} ops.

Since the former alternative is prefered, we may want to remove the
latter soon from DSA. If this phy_port_map is needed for that case, it'd
be preferable not to add it.

Thanks,

        Vivien
