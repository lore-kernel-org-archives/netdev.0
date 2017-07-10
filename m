From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] mdio: mux: fix parsing mux registers outside of the
 PHY address range
Date: Mon, 10 Jul 2017 14:56:52 +0200
Message-ID: <20170710125652.GG1616@lunn.ch>
References: <20170710123523.6625-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
        linux-amlogic@lists.infradead.org, jon.mason@broadcom.com
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49420 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753800AbdGJM44 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 08:56:56 -0400
Content-Disposition: inline
In-Reply-To: <20170710123523.6625-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 10, 2017 at 02:35:23PM +0200, Martin Blumenstingl wrote:
> mdio_mux_init parses the child nodes of the MDIO mux. When using
> "mdio-mux-mmioreg" the child nodes are describing the register value
> that is written to switch between the MDIO busses.
> 
> The change which makes the error messages more verbose changed the
> parsing of the "reg" property from a simple of_property_read_u32 call
> to of_mdio_parse_addr. On a Khadas VIM (based on the Meson GXL SoC,
> which uses mdio-mux-mmioreg) this prevents registering the MDIO mux
> (because the "reg" values on the MDIO mux child nodes are 0x2009087f
> and 0xe40908ff) and leads to the following errors:
>   mdio-mux-mmioreg c883455c.eth-phy-mux: /soc/periphs@c8834000/eth-phy-mux/mdio@e40908ff PHY address -469169921 is too large
>   mdio-mux-mmioreg c883455c.eth-phy-mux: Error: Failed to find reg for child /soc/periphs@c8834000/eth-phy-mux/mdio@e40908ff
>   mdio-mux-mmioreg c883455c.eth-phy-mux: /soc/periphs@c8834000/eth-phy-mux/mdio@2009087f PHY address 537462911 is too large
>   mdio-mux-mmioreg c883455c.eth-phy-mux: Error: Failed to find reg for child /soc/periphs@c8834000/eth-phy-mux/mdio@2009087f
>   mdio-mux-mmioreg c883455c.eth-phy-mux: Error: No acceptable child buses found
>   mdio-mux-mmioreg c883455c.eth-phy-mux: failed to register mdio-mux bus /soc/periphs@c8834000/eth-phy-mux
> (as a result of that ethernet is not working, because the PHY which is
> connected through the mux' child MDIO bus, which is not being
> registered).
> 
> Fix this by reverting the change from of_mdio_parse_addr to
> of_mdio_parse_addr.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Yes, validating the reg property needs to be done separately in each
user of the generic mdio-mix code. The reg for the gpio mux must be <=
number of gpios, mmioreg must be somewhere within the address space,
bcm-iproc < 1024?

Jon, please feel free to add such code.

    Andrew
