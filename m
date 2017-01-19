From: Mason <slash.tmp@free.fr>
Subject: Re: Setting link down or up in software
Date: Thu, 19 Jan 2017 16:40:04 +0100
Message-ID: <1ac88f50-30c5-fbaf-11ff-2d42490b5801@free.fr>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
 <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
 <0273a4ad-46f7-d7b9-a206-6bd713e6165e@neratec.com>
 <9be9b48d-1bef-b48f-866f-8651d9b9c245@free.fr>
 <bfe5bd8b-d4eb-8c8e-45d8-6ea1c133b4a7@neratec.com>
 <660b7b17-0136-bf69-fd12-1c125069829b@free.fr>
 <dc6378d7-d370-c893-63b7-c21cd7ef76fd@neratec.com>
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
Received: from smtp5-g21.free.fr ([212.27.42.5]:35564 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753290AbdASPk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 10:40:27 -0500
In-Reply-To: <dc6378d7-d370-c893-63b7-c21cd7ef76fd@neratec.com>
Content-Language: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/01/2017 11:29, Zefir Kurtisi wrote:
> On 01/13/2017 06:35 PM, Mason wrote:
>> On 13/01/2017 17:28, Zefir Kurtisi wrote:
>>
>>> As for your specific problem: since I fought myself with the PHY/ETH subsystems
>>> over the past months, I might remember something relevant to your issue. Could you
>>> give some more info on your setup (PHY driver, opmode (SGMII, RGMII, etc.), ETH).
>>
>> Hello Zefir,
>>
>> My boards are using these drivers:
>>
>> http://lxr.free-electrons.com/source/drivers/net/ethernet/aurora/nb8800.c
>> http://lxr.free-electrons.com/source/drivers/net/phy/at803x.c
>>
>> The relevant device tree nodes are:
>>
>> 		eth0: ethernet@26000 {
>> 			compatible = "sigma,smp8734-ethernet";
>> 			reg = <0x26000 0x800>;
>> 			interrupts = <38 IRQ_TYPE_LEVEL_HIGH>;
>> 			clocks = <&clkgen SYS_CLK>;
>> 		};
>>
>> &eth0 {
>> 	phy-connection-type = "rgmii";
>> 	phy-handle = <&eth0_phy>;
>> 	#address-cells = <1>;
>> 	#size-cells = <0>;
>>
>> 	/* Atheros AR8035 */
>> 	eth0_phy: ethernet-phy@4 {
>> 		compatible = "ethernet-phy-id004d.d072",
>> 			     "ethernet-phy-ieee802.3-c22";
>> 		interrupts = <37 IRQ_TYPE_EDGE_RISING>;
>> 		reg = <4>;
>> 	};
>> };
>>
>> If I comment the PHY "interrupts" property, then the PHY framework
>> falls back to polling.
>>
>> Am I forgetting important information?
> 
> In our system we attach the at8031 over SGMII to the gianfar (Freescale eTSEC) and
> to fibre optics transceivers, which operate in fixed speeds. Getting this setup to
> work reliably was challenging for various reasons, maybe worth to note
> 
> 1) fixed SGMII speed not working: link is up on both ends, but no data is passed
> 2) known issue with SGMII link not completing autonegotiation correctly, see [1]
> 3) once autoneg is started or chip is reset, MII_CTRL1000 can not be written to
> until autoneg is completed => breaks phy state machine when the driver loads with
> unplugged cable and tries to set fixed speed
> 
> Unless you are using fixed speed links in your setup, none of those should affect
> it. My experience with at8031 attached to RGMII is that it is genphy compliant,
> therefore I would a) disable interrupts, and b) prevent loading at803x.ko and try
> the genphy instead. Yours is an at8035, results may vary.
> 
> [1] https://www.spinics.net/lists/netdev/msg400804.html

Hello Zefir,

Thanks for having a look at my issue.

I must confess that I'm not up to speed on the different *MIIs
(MII, RMII, GMII, RGMII, SGMII, etc)

One thing I find confusing... If the 8035 could work with the generic
PHY driver, what's the point of the at803x.ko driver?

Regards.
