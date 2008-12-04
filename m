From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: "eth1: Could not attach to PHY" on MPC8349e-MITX
Date: Thu, 4 Dec 2008 20:56:34 +0300
Message-ID: <20081204175634.GA31505@oksana.dev.rtsoft.ru>
References: <ed82fe3e0812040915i696e99bep75a37b0e38154415@mail.gmail.com> <49381662.2020302@matrix-vision.de> <493817AE.1070303@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Andre Schwarz <andre.schwarz@matrix-vision.de>,
	linuxppc-dev@ozlabs.org, afleming@freescale.com,
	netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:6601 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753374AbYLDR4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 12:56:35 -0500
Content-Disposition: inline
In-Reply-To: <493817AE.1070303@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 04, 2008 at 11:47:26AM -0600, Timur Tabi wrote:
> Andre Schwarz wrote:
> > Timur,
> > 
> > is it possible that the PHY adress doesn't match the one specified in
> > the dts ?
> 
> What part of the DTS contains the PHY address?  I have this:
> 
> 	mdio@24520 {
> 		#address-cells = <1>;
> 		#size-cells = <0>;
> 		compatible = "fsl,gianfar-mdio";
> 		reg = <0x24520 0x20>;
> 
> 		/* Vitesse 8201 */
> 		phy1c: ethernet-phy@1c {
> 			interrupt-parent = <&ipic>;
> 			interrupts = <18 0x8>;
> 			reg = <0x1c>;
> 			device_type = "ethernet-phy";
> 		};
> 	};
> 
> 	enet1: ethernet@25000 {
> 		cell-index = <1>;
> 		device_type = "network";
> 		model = "TSEC";
> 		compatible = "gianfar";
> 		reg = <0x25000 0x1000>;
> 		local-mac-address = [ 00 00 00 00 00 00 ];
> 		interrupts = <35 0x8 36 0x8 37 0x8>;
> 		phy-connection-type = "mii";
> 		interrupt-parent = <&ipic>;
> 		/* Vitesse 7385 isn't on the MDIO bus */
> 		fixed-link = <1 1 1000 0 0>;

^^^ That one. The Vitesse 7385 isn't on the MDIO bus, so the fixed
link (drivers/net/phy/fixed.c) driver is used for this ethernet port.

> 		linux,network-index = <1>;
> 	};

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
