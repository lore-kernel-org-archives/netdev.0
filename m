From: Timur Tabi <timur@freescale.com>
Subject: Re: "eth1: Could not attach to PHY" on MPC8349e-MITX
Date: Thu, 04 Dec 2008 11:47:26 -0600
Message-ID: <493817AE.1070303@freescale.com>
References: <ed82fe3e0812040915i696e99bep75a37b0e38154415@mail.gmail.com> <49381662.2020302@matrix-vision.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com
To: Andre Schwarz <andre.schwarz@matrix-vision.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:44046 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbYLDRsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 12:48:18 -0500
In-Reply-To: <49381662.2020302@matrix-vision.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andre Schwarz wrote:
> Timur,
> 
> is it possible that the PHY adress doesn't match the one specified in
> the dts ?

What part of the DTS contains the PHY address?  I have this:

	mdio@24520 {
		#address-cells = <1>;
		#size-cells = <0>;
		compatible = "fsl,gianfar-mdio";
		reg = <0x24520 0x20>;

		/* Vitesse 8201 */
		phy1c: ethernet-phy@1c {
			interrupt-parent = <&ipic>;
			interrupts = <18 0x8>;
			reg = <0x1c>;
			device_type = "ethernet-phy";
		};
	};

	enet1: ethernet@25000 {
		cell-index = <1>;
		device_type = "network";
		model = "TSEC";
		compatible = "gianfar";
		reg = <0x25000 0x1000>;
		local-mac-address = [ 00 00 00 00 00 00 ];
		interrupts = <35 0x8 36 0x8 37 0x8>;
		phy-connection-type = "mii";
		interrupt-parent = <&ipic>;
		/* Vitesse 7385 isn't on the MDIO bus */
		fixed-link = <1 1 1000 0 0>;
		linux,network-index = <1>;
	};

-- 
Timur Tabi
Linux kernel developer at Freescale
