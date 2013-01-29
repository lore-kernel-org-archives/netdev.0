From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH 5/5] mv643xx_eth: convert to use the Marvell Orion MDIO
 driver
Date: Tue, 29 Jan 2013 11:13:06 -0700
Message-ID: <20130129181306.GF25646@obsidianresearch.com>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
 <1359473048-26551-6-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, linux-doc@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	linux-arm-kernel@lists.infradead.org,
	Rob Landley <rob@landley.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1359473048-26551-6-git-send-email-florian@openwrt.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 29, 2013 at 04:24:08PM +0100, Florian Fainelli wrote:
> This patch converts the Marvell MV643XX ethernet driver to use the
> Marvell Orion MDIO driver. As a result, PowerPC and ARM platforms
> registering the Marvell MV643XX ethernet driver are also updated to
> register a Marvell Orion MDIO driver. This driver voluntarily overlaps
> with the Marvell Ethernet shared registers because it will use a subset
> of this shared register (shared_base + 0x4 - shared_base + 0x84). The
> Ethernet driver is also updated to look up for a PHY device using the
> Orion MDIO bus driver.

Can you finish off this job by making the mv643xx_eth driver accept
the standard phy-handle OF property instead of using a phy address?

Ie the end result should be something like:

                smi0: mdio@72000 {
                        device_type = "mdio";
                        compatible = "marvell,orion-mdio";
                        reg = <0x72004 0x4>;

                        #address-cells = <1>;
                        #size-cells = <0>;
                        PHY1: ethernet-phy@1 {
                                reg = <1>;
                                device_type = "ethernet-phy";
                                phy-id = <0x01410e90>;
                        };
                };

                egiga0 {
                        device_type = "network";
                        compatible = "marvell,mv643xx-eth";
                        reg = <0x72000 0x4000>;
                        port_number = <0>;
                        phy-handle = <&PHY1>;
                        interrupts = <11>;
                        local-mac-address = [000000000002];  /* Filled by boot loader */
                };

Regards,
Jason
