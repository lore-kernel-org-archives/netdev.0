From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Tue, 19 Jan 2010 23:11:00 +0100
Message-ID: <4B562DF4.70302@openwrt.org>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com> <e2d7436a1001160800u11206f54iaf07bb92331a256a@mail.gmail.com> <4B51E64B.6010706@openwrt.org> <14385191E87B904DBD836449AA30269D580AA0@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michael Buesch <mb@bu3sch.de>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
To: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:57703 "EHLO ds10.nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754705Ab0ASWLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 17:11:10 -0500
In-Reply-To: <14385191E87B904DBD836449AA30269D580AA0@MORGANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-01-19 10:51 PM, Ha, Tristram wrote:
> Your work looks interesting, but rtl8036 seems to use MDIO page
> registers to access its own internal registers.  Micrel switches do
> not have that feature and so cannot use that way.
> 
> I am looking at those PHY drivers and try to figure out how they work
> under mdio bus.  I am using Micrel's own KSZ8695P and KSZ9692P SoC to
> develop and debug the KSZ884X PCI driver.  KSZ9692P actually has two
> external PHYs so that the PHY driver can run on it.  But the driver
> does not load because I probably need to add some hooks to the mdio
> bus driver to do the actual hardware access.  Can somebody give me
> some pointers to this mdio bus support?  Does the PHY driver create a
> user interface like eth0 so that it can be accessed using some tools
> like ethtool?
> 
> Anyway I am afraid the phy driver model does not work on KSZ884X.  I
> cannot think of how the mdio bus accesses hardware registers located
> on a PCI device.
The switch config core that i wrote is not specific to PHY drivers, it
can be used from ethernet drivers, GPIO based platform drivers or any
other kind of drivers as well.
It exports a simple netlink based config interface to user space that
allows you to get a list of all configurable attributes for the device,
ports and vlans, and change them.

I also have a config utility for it:
https://dev.openwrt.org/browser/trunk/package/swconfig/src

It currently depends on our config library (libuci), but that can be
removed easily, as the code for that is not spread over the core of the
utility.

Part of this code can also be used as a small library, if you want to
write your own utility.

- Felix
