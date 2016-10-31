From: Mason <slash.tmp@free.fr>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Mon, 31 Oct 2016 16:48:15 +0100
Message-ID: <581767BF.4020308@free.fr>
References: <58176355.7090200@free.fr> <20161031153704.GD9441@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:45985 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932217AbcJaPsl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 11:48:41 -0400
In-Reply-To: <20161031153704.GD9441@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/10/2016 16:37, Andrew Lunn wrote:

>> The regnum=5,4,1,1,a,9 logs keep repeating, endlessly.
>> Is that expected?
> 
> Yes, that is expected, if you are not using interrupts. The phylib
> state machine polls the state of the PHY once per second to see if
> there has been a link up/down.

Interesting. But the logs are showing accesses much more frequent
than once per second, it seems... (?)

And an interrupt for the PHY is configured in the device tree:

&eth0 {
	#address-cells = <1>;
	#size-cells = <0>;
	phy-connection-type = "rgmii";
	phy-handle = <&eth0_phy>;

	/* Atheros AR8035 */
	eth0_phy: ethernet-phy@4 {
		compatible = "ethernet-phy-id004d.d072",
			     "ethernet-phy-ieee802.3-c22";
		interrupts = <37 IRQ_TYPE_EDGE_RISING>;
		reg = <4>;
	};
};

I'll add a log for the request_irq call.

Regards.
