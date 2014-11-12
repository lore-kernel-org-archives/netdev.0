From: Bruno Thomsen <bth@kamstrup.dk>
Subject: RE: phy/micrel: KSZ8031RNL RMII clock reconfiguration bug
Date: Wed, 12 Nov 2014 12:17:57 +0000
Message-ID: <915054555B5659448ACF8A70E114824D01704B9131@Exchange2010.kamstrup.dk>
References: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
 <20141111194101.GI29789@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>,
	"bruno.thomsen@gmail.com" <bruno.thomsen@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Johan Hovold <johan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kamstrup.com ([93.167.225.188]:40890 "EHLO
	mail.kamstrup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177AbaKLMSC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 07:18:02 -0500
In-Reply-To: <20141111194101.GI29789@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johan,

> As you may have seen by now, I've been working on refactoring the micrel phy driver to be able to use common initialisation code.
>
> Specifically, I've added generic support for disabling the broadcast address, which is what the MII_KSZPHY_OMSO write above does.
>
> Generally you want this to be the first thing you do in order to avoid unnecessary reconfigurations. If we ever were to allow concurrent probing this would also be a requirement.
>
> Could you provide some detail about the setup were you find that the PHY becomes unresponsive without your patch? Do you have more than one PHY on the bus? Using what addresses? And using what clock modes (i.e. 25 MHz or 50 MHz)?
> 
> Also, what exactly do you mean by "unresponsive"? Are you still able to read the PHY registers for example?

I think it sounds like a good idea to refactor the init code.

My setup:
iMX28 processor with dual Ethernet MAC; FEC0 (enabled) and FEC1 (disabled).
There is a single KSZ8031 PHY that receives 50MHz RMII clock from the MAC.
I am unable to read PHY registers from both user-land tools and extra debug PHY reads in driver code.

Boot trace:
[   22.277785] fec 800f0000.ethernet eth0: Freescale FEC PHY driver [Micrel KSZ8031] (mii_bus:phy_addr=800f0000.etherne:00, irq=-1)
[   22.292527] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   24.276217] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
[   24.285094] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready


Venlig hilsen / Best regards

Kamstrup A/S <http://www.kamstrup.dk> 
Bruno Thomsen
Development engineer
Technology

Kamstrup A/S
Industrivej 28
DK-8660 Skanderborg
Tel:	 +45 89 93 10 00	 
Fax:	 +45 89 93 10 01	 
Dir:	 +45 89 93 13 94	 
E-mail:	 bth@kamstrup.dk	 
Web:	 www.kamstrup.dk
