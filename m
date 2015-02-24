From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Tue, 24 Feb 2015 22:51:55 +0100
Message-ID: <20150224215155.GA15633@lunn.ch>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jonas Gorski <jogo@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Rafa?? Mi??ecki <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48704 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbbBXVy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 16:54:56 -0500
Content-Disposition: inline
In-Reply-To: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 06:42:07PM +0100, Rafa?? Mi??ecki wrote:
> BCM53xx is series of Broadcom Ethernet switches that can be found in
> various (mostly home) routers.
> They are quite simple switches with mainly just support for:
> 1) Tagging incoming packets (PVID)
> 2) Untagging outgoing packets
> 3) Forwarding all packets across a single VLAN
> 
> This driver is split into common code (module) and bus specific code.
> Right now only PHY (MDIO) support is included, other could follow after
> accepting this driver. It was successfully tested on BCM4706 SoC with
> BCM53125.
> 
> You could notice it's yet another try of submitting b53 driver. This
> time it was modified to use recently introduced switchdev API which
> hopefully make it possible to accept it mainline.
> 
> Signed-off-by: Rafa?? Mi??ecki <zajec5@gmail.com>
> ---
> Example usage. My BCM4706 router has switch with 6 ports:
> 0: WAN port
> 1-4: LAN ports
> 8: CPU connected port (on-SoC Ethernet device)
> 
> I decided to use VLAN 1 for WAN and VLAN 2 for LAN. I was able to
> successfully configure it using:
> 
> bridge vlan add vid 1 dev sw0p1 pvid untagged
> bridge vlan add vid 1 dev sw0p2 pvid untagged
> bridge vlan add vid 1 dev sw0p3 pvid untagged
> bridge vlan add vid 1 dev sw0p4 pvid untagged
> bridge vlan add vid 1 dev sw0p8
> 
> bridge vlan add vid 2 dev sw0p0 pvid untagged
> bridge vlan add vid 2 dev sw0p8
> ---
>  drivers/net/phy/Kconfig          |   2 +
>  drivers/net/phy/Makefile         |   1 +
>  drivers/net/phy/b53/Kconfig      |  12 +
>  drivers/net/phy/b53/Makefile     |   2 +
>  drivers/net/phy/b53/b53_common.c | 961 +++++++++++++++++++++++++++++++++++++++
>  drivers/net/phy/b53/b53_mdio.c   | 418 +++++++++++++++++
>  drivers/net/phy/b53/b53_priv.h   | 299 ++++++++++++
>  drivers/net/phy/b53/b53_regs.h   | 313 +++++++++++++

Hi Rafa??

I have a question about the location. Why drivers/net/phy?

  Andrew
