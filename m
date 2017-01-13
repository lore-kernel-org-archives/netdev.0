From: Mason <slash.tmp@free.fr>
Subject: Re: Setting link down or up in software
Date: Fri, 13 Jan 2017 18:35:57 +0100
Message-ID: <660b7b17-0136-bf69-fd12-1c125069829b@free.fr>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
 <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
 <0273a4ad-46f7-d7b9-a206-6bd713e6165e@neratec.com>
 <9be9b48d-1bef-b48f-866f-8651d9b9c245@free.fr>
 <bfe5bd8b-d4eb-8c8e-45d8-6ea1c133b4a7@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:64677 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750818AbdAMRgP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 12:36:15 -0500
In-Reply-To: <bfe5bd8b-d4eb-8c8e-45d8-6ea1c133b4a7@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/2017 17:28, Zefir Kurtisi wrote:

> As for your specific problem: since I fought myself with the PHY/ETH subsystems
> over the past months, I might remember something relevant to your issue. Could you
> give some more info on your setup (PHY driver, opmode (SGMII, RGMII, etc.), ETH).

Hello Zefir,

My boards are using these drivers:

http://lxr.free-electrons.com/source/drivers/net/ethernet/aurora/nb8800.c
http://lxr.free-electrons.com/source/drivers/net/phy/at803x.c

The relevant device tree nodes are:

		eth0: ethernet@26000 {
			compatible = "sigma,smp8734-ethernet";
			reg = <0x26000 0x800>;
			interrupts = <38 IRQ_TYPE_LEVEL_HIGH>;
			clocks = <&clkgen SYS_CLK>;
		};

&eth0 {
	phy-connection-type = "rgmii";
	phy-handle = <&eth0_phy>;
	#address-cells = <1>;
	#size-cells = <0>;

	/* Atheros AR8035 */
	eth0_phy: ethernet-phy@4 {
		compatible = "ethernet-phy-id004d.d072",
			     "ethernet-phy-ieee802.3-c22";
		interrupts = <37 IRQ_TYPE_EDGE_RISING>;
		reg = <4>;
	};
};

If I comment the PHY "interrupts" property, then the PHY framework
falls back to polling.

Am I forgetting important information?

Regards.
