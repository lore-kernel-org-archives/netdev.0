From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/4] net: mvneta: driver for Marvell Armada 370/XP network unit
Date: Wed, 31 Oct 2012 12:12:29 +0100
Message-ID: <2760802.TcHGXAmZie@bender>
References: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com> <1351245804-31478-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33224 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933211Ab2JaLMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 07:12:40 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so580121bkc.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 04:12:38 -0700 (PDT)
In-Reply-To: <1351245804-31478-2-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

On Friday 26 October 2012 12:03:21 Thomas Petazzoni wrote:
> This patch contains a new network driver for the network unit of the
> ARM Marvell Armada 370 and the Armada XP. Both SoCs use the PJ4B
> processor, a Marvell-developed ARM core that implements the ARMv7
> instruction set.
> 
> Compared to previous ARM Marvell SoCs (Kirkwood, Orion, Discovery),
> the network unit in Armada 370 and Armada XP is highly different. This
> is the reason why this new 'mvneta' driver is needed, while the older
> ARM Marvell SoCs use the 'mv643xx_eth' driver.
> 
> Here is an overview of the most important hardware changes that
> require a new, specific, driver for the network unit of Armada 370/XP:
> 
>  - The new network unit has a completely different design and layout
>    for the RX and TX descriptors. They are now organized as a simple
>    array (each RX and TX queue has base address and size of this
>    array) rather than a linked list as in the old SoCs.
> 
>  - The new network unit has a different RXQ and TXQ management: this
>    management is done using special read/write counter registers,
>    while in the Old SocS, it was done using the Ownership bit in RX
>    and TX descriptors.
> 
>  - The new network unit has different interrupt registers
> 
>  - The new network unit way of cleaning of interrupts is not done by
>    writing to the cause register, but by updating per-queue counters
> 
>  - The new network unit has different GMAC registers (link, speed,
>    duplex configuration) and different WRR registers.
> 
>  - The new network unit has lots of new units like PnC (Parser and
>    Classifier), PMT, BM (Memory Buffer Management), xPON, and more.
> 
> The driver proposed in the current patch only handles the basic
> features. Additional hardware features will progressively be supported
> as needed.
> 
> This code has originally been written by Rami Rosen
> <rosenr@marvell.com>, and then reviewed and cleaned up by Thomas
> Petazzoni <thomas.petazzoni@free-electrons.com>.

This is looking good from a PHY lib point of view now, thanks for doing this!
-- 
Florian
