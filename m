From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: davinci-mdio: failing to connect to PHY
Date: Mon, 4 Apr 2016 15:58:13 +0200
Message-ID: <20160404135813.GA25131@lunn.ch>
References: <57022356.6010309@barix.com>
 <20160404123145.GE21828@lunn.ch>
 <5702710A.5010804@barix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Petr Kulhavy <petr@barix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45816 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755504AbcDDN6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 09:58:14 -0400
Content-Disposition: inline
In-Reply-To: <5702710A.5010804@barix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 03:50:02PM +0200, Petr Kulhavy wrote:
> 
> 
> On 04.04.2016 14:31, Andrew Lunn wrote:
> >Hi Petr
> >
> >You might want to take a look at:
> >
> >http://lxr.free-electrons.com/source/drivers/net/ethernet/ti/davinci_mdio.c#L137
> >
> >It seems to be asking the hardware about the phy mask.
> >
> >    Andrew
> 
> Hi Andrew,
> 
> thanks a lot for the link. In the meantime I've understood the issue
> better. It is due to the fact that the PHY is pin-strapped to
> address 1 and broadcast (at address 0) is  enabled. The Micrel
> driver's config_init() disables the broadcast and the PHY stops
> responding, which causes the troubles. The kernel 3.17 didn't
> disable the broadcast and therefore it worked.
> 
> I'm wondering how to solve or workaround this...

One option is in your device tree is to explicitly list the phy on
your mdio bus. Something like:

&mdio {
        status = "okay";

        ethphy0: ethernet-phy@1 {
                reg = <1>;
        };
};

This alone might be sufficient. If not, you need to reference the phy
via a phandle in the ethernet node.


&eth0 {
        status = "okay";
        phy-handle = <&ethphy0>;
};

	Andrew
