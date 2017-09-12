From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v5 10/10] net: stmmac: dwmac-sun8i: Handle
 integrated/external MDIOs
Date: Tue, 12 Sep 2017 09:54:15 +0200
Message-ID: <20170912075415.GA1358@Red>
References: <20170908071156.5115-11-clabbe.montjoie@gmail.com>
 <20170908130520.GA11248@lunn.ch>
 <20170908132632.GA3037@Red>
 <20170908140020.GC25219@lunn.ch>
 <20170908140832.GB3037@Red>
 <20170908141736.GF25219@lunn.ch>
 <20170908142825.GC3037@Red>
 <20170911161124.GD27599@lunn.ch>
 <20170911190850.GA2291@Red>
 <20170911201920.GA5983@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170911201920.GA5983@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 11, 2017 at 10:19:20PM +0200, Andrew Lunn wrote:
> > Even with CLK_BUS_EPHY/RST_BUS_EPHY enabled, the MAC reset timeout.
> > So no the CLK/RST are really for the PHY.
> 
> Thanks for trying that.
> 
> You said it was probably during scanning of the bus it times out. What
> address is causing the timeout? 0 or 1? If the internal bus can only
> have one PHY on it, maybe we need to set bus->phy_mask to 0x1?
> 

I have added a trace in begin and end of stmmac_mdio_read()

[   18.145451] libphy: stmmac: probed
[   18.148398] libphy: mdio_mux: probed
[   18.148650] dwmac-sun8i 1c30000.ethernet: Switch mux to internal PHY
[   18.248751] dwmac-sun8i 1c30000.ethernet: EMAC reset timeout
[   18.249297] libphy: mdio_mux: probed
[   18.249362] dwmac-sun8i 1c30000.ethernet: Switch mux to external PHY
[   18.249391] stmmac_mdio_read 0 2
[   18.249598] stmmac_mdio_read 0 2 1c
[   18.249623] stmmac_mdio_read 0 3
[   18.249811] stmmac_mdio_read 0 3 c915
[   20.737271] EXT4-fs (mmcblk0p1): re-mounted. Opts: (null)
[   31.294868] stmmac_mdio_read 0 0
[   31.295311] stmmac_mdio_read 0 0 1140

It seems that the timeout is unrelated to MDIO bus.

Regards
