From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] mvneta: add FIXED_PHY dependency
Date: Mon, 9 Nov 2015 17:08:34 +0000
Message-ID: <20151109170834.GE8644@n2100.arm.linux.org.uk>
References: <4225885.EYXTHjRPmX@wuerfel>
 <20151109164232.GB3388@lunn.ch>
 <6910088.dNmooXDTJR@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6910088.dNmooXDTJR@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 09, 2015 at 05:57:43PM +0100, Arnd Bergmann wrote:
> I'm not sure what you are asking. A lot of DT bindings have both
> optional and mandatory properties. For mvneta, the "phy" and "phy-mode"
> properties are listed as mandatory, so the driver can safely assume
> that they are always present. If there are reasons to leave them out,
> and for the driver to handle that case correctly, the binding
> should be updated to mark them as optional.

They are "optional" because when you're using a DSA switch, you don't
specify a PHY (because, there isn't one).  For example, this is what
I'm using with an Armada 388 board with a Marvell DSA switch.  The
DSA does not appear as a PHY, and no node in the DSA stanza can be
referenced for a phy entry in the ethernet device's stanza.

                        eth1: ethernet@30000 {
                                compatible = "marvell,armada-370-neta";
                                reg = <0x30000 0x4000>;
                                interrupts-extended = <&mpic 10>;
                                clocks = <&gateclk 3>;
                                managed = "in-band-status";
                                phy-mode = "sgmii";
                                status = "okay";
                        };

        dsa@0 {
                compatible = "marvell,dsa";
                dsa,ethernet = <&eth1>;
                dsa,mii-bus = <&mdio>;
                pinctrl-0 = <&clearfog_dsa0_clk_pins &clearfog_dsa0_pins>;
                pinctrl-names = "default";
                #address-cells = <2>;
                #size-cells = <0>;

                switch@0 {
		...
		};
	};

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
