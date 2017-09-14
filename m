From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 05/10] dt-bindings: net: dwmac-sun8i: update
 documentation about integrated PHY
Date: Thu, 14 Sep 2017 21:19:49 +0200
Message-ID: <20170914191949.GA3796@lunn.ch>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-6-clabbe.montjoie@gmail.com>
 <20170908072538.rqsp6dobwsqmzrsr@flea.lan>
 <20170908074325.GB29999@Red>
 <20170913182004.uniyo5opeilcfk7r@rob-hp-laptop>
 <20170914185301.GB4021@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh@kernel.org>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        mark.rutland@arm.com, wens@csie.org, linux@armlinux.org.uk,
        catalin.marinas@arm.com, will.deacon@arm.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170914185301.GB4021@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Is the MDIO controller "allwinner,sun8i-h3-emac" or "snps,dwmac-mdio"? 
> > If the latter, then I think the node is fine, but then the mux should be 
> > a child node of it. IOW, the child of an MDIO controller should either 
> > be a mux node or slave devices.

Hi Rob

Up until now, children of an MDIO bus have been MDIO devices. Those
MDIO devices are either Ethernet PHYs, Ethernet Switches, or the
oddball devices that Broadcom iProc has, like generic PHYs.

We have never had MDIO-muxes as MDIO children. A Mux is not an MDIO
device, and does not have the properties of an MDIO device. It is not
addressable on the MDIO bus. The current MUXes are addressed via GPIOs
or MMIO.

There other similar cases. i2c-mux-gpio is not a child of an i2c bus,
nor i2c-mux-reg or gpio-mux. nxp,pca9548 is however a child of the i2c
bus, because it is an i2c device itself...

If the MDIO mux was an MDIO device, i would agree with you. Bit it is
not, so lets not make it a child.

	    Andrew
