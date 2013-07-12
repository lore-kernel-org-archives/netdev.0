From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: Fixed PHY Device Tree usage?
Date: Fri, 12 Jul 2013 15:04:49 +0200
Message-ID: <20130712150449.4077feb4@skate>
References: <20130709183312.6c4d052d@skate>
	<CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
	<1733937.SiPWt3mDlH@lenovo>
	<20130710182216.0dcfaaaf@skate>
	<CAGVrzcbt302tTM3pprnhJz7YykUzcW=XSMCr_W=m1zWiVBX8kw@mail.gmail.com>
	<20130710183951.09a0bcea@skate>
	<CAGVrzcasmv6KvEN+okkcQA9CHjCtuRqcd=AvKLiFbPXiyS-P=w@mail.gmail.com>
	<20130712135612.0f230c1d@skate>
	<CAGVrzcax7gWCbdDKLdDjQDV_fOsShh+VZ9ODKO2KUBPm-zQgpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"grant.likely" <grant.likely@secretlab.ca>, afleming@freescale.com
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:50093 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933008Ab3GLNE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 09:04:58 -0400
In-Reply-To: <CAGVrzcax7gWCbdDKLdDjQDV_fOsShh+VZ9ODKO2KUBPm-zQgpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Fri, 12 Jul 2013 13:05:59 +0100, Florian Fainelli wrote:

> I am talking about scanning the MDIO bus DT nodes, not the entire DT.
> That job is already done by of_mdiobus_probe() to register PHY
> devices, so having a central point where the knowledge of how to treat
> PHY deivces could be here I guess.

So, I guess your idea is to call of_mdiobus_register() from
drivers/net/phy/fixed.c:fixed_mdio_bus_init(). But then, what DT node
will you be passing to of_mdiobus_register() ? As a reminder, this
function takes as a second argument the DT node that contains the
various PHYs as sub-nodes.

In all the other PHY drivers, the MDIO bus node as a compatible string,
so the usual platform_driver/platform_device mechanism kicks in, and
calls the ->probe() function, passing the DT node of the MDIO bus,
which is then used by the PHY driver ->probe() function as the second
argument of of_mdiobus_register().

But the fixed.c PHY driver is not a platform_driver, and in our
discussion, we mentioned that it wouldn't make sense to have a
compatible string for the fixed MDIO bus DT node.

So I'm still unsure *which* DT node you'll pass as the second argument
of of_mdiobus_register() :-)


> Well either we go with some specific compatible property like
> "ethernet-phy-fixed" for instance, or we simply add a boolean property
> to the node, so a fixed PHY would either look like this:
> 
> phy {
>          compatible = "linux,ethernet-phy-fixed";
>          speed = <1000>;
>          duplex = <1>;
>          pause;
>          asym-pause;
> };
> 
> or respectively, something like this:
> 
> phy {
>          fixed;
>          speed = <1000>;
>          duplex = <1>;
>          pause;
>          asym-pause;
> };

Yeah, that's fine, I have no problem with the internal properties of
the PHY nodes themselves. My question is really the one described above.

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
