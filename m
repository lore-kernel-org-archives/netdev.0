From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mdio: mux: fix parsing mux registers outside of
 the PHY address range
Date: Fri, 14 Jul 2017 08:13:18 -0700 (PDT)
Message-ID: <20170714.081318.505725392656343819.davem@davemloft.net>
References: <20170710123523.6625-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-amlogic@lists.infradead.org, jon.mason@broadcom.com
To: martin.blumenstingl@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36128 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754031AbdGNPNW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 11:13:22 -0400
In-Reply-To: <20170710123523.6625-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Date: Mon, 10 Jul 2017 14:35:23 +0200

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
> 
> Fixes: 342fa1964439 ("mdio: mux: make child bus walking more permissive and errors more verbose")
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>

Applied, thanks.
