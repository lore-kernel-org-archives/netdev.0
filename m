From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: macb: Add mdio driver for accessing multiple
 phy devices
Date: Mon, 13 Jul 2015 11:43:10 -0700
Message-ID: <55A406BE.5090300@gmail.com>
References: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: harinik@xilinx.com, kpc528@gmail.com,
	kalluripunnaiahchoudary@gmail.com, netdev@vger.kernel.org,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>
To: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	nicolas.ferre@atmel.com, michals@xilinx.com, anirudh@xilinx.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35172 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbGMUfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 16:35:52 -0400
Received: by pactm7 with SMTP id tm7so212893471pac.2
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 13:35:51 -0700 (PDT)
In-Reply-To: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/15 21:48, Punnaiah Choudary Kalluri wrote:
> This patch is to add support for the design that has multiple ethernet
> mac controllers and single mdio bus connected to multiple phy devices.
> i.e mdio lines are connected to any of the ethernet mac controller and
> all the phy devices will be accessed using the phy maintenance interface
> in that mac controller.
> 
>  ______                   _____
> |      |                 |PHY0 |
> | MAC0 |-----------------|     |
> |______|       |         |_____|
>                |           
>  ______        |          _____
> |      |       |         |     |
> | MAC1 |       |_________|PHY1 | 
> |______|                 |____ |
> 
> So, i come up with two implementations for addressing the above configuration.
> 
> Implementation 1:
>  Have separate driver for mdio bus
>  Create a DT node for all the PHY devices connected to the mdio bus
>  This driver will share the register space of the mac controller that has
>  mdio bus connected.

That is the best design implementation, MDIO in itself is a sub-piece of
your Ethernet MAC controller the fact that it is within the Ethernet MAC
core is just coincidental, but there is no reason why it could not be
taken apart and made a separate block in itself.

> 
> Implementation 2:
>  Add new property "has-mdio" and it should be 1 for the mac that has mdio bus
>  connected.
>  Create the mdio bus only when the has-mdio property is 1
> 
> Please review the two implementations and suggest which one is better to proceed
> further. In my opinion implementation 1 will be the ideal one.

Agreed.

> 
> Currently i have tested the patches with single mac and single phy
> configuration. I need to take care of few more cases before releasing the final patch
> but before that i would like to have your opinion on the above implementations
> and finalize one implementation. so that i can enhance it further.
> 
> Punnaiah Choudary Kalluri (1):
>   net: macb: Add mdio driver for accessing multiple phy devices
>   net: macb: Add support for single mac managing more than one phy
> 
> 
>  drivers/net/ethernet/cadence/Makefile    |    2 +-
>  drivers/net/ethernet/cadence/macb.c      |   93 +-------------
>  drivers/net/ethernet/cadence/macb.h      |    3 +-
>  drivers/net/ethernet/cadence/macb_mdio.c |  204 ++++++++++++++++++++++++++++++
>  4 files changed, 211 insertions(+), 91 deletions(-)
>  create mode 100644 drivers/net/ethernet/cadence/macb_mdio.c
> 


-- 
Florian
