From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RESEND PATCH net 06/10] net: ethernet: mediatek: fix the loss
Date: Fri, 26 Aug 2016 16:17:59 +0200
Message-ID: <20160826141759.GG25046@lunn.ch>
References: <20160825133034.GA25046@lunn.ch>
 <1472182419-17998-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@phrozen.org, davem@davemloft.net, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com
To: Sean Wang <sean.wang@mediatek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45093 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750979AbcHZOSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 10:18:09 -0400
Content-Disposition: inline
In-Reply-To: <1472182419-17998-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Andrew,
> 
> Here pinctrl is used to setup what function the group of the pins is
> for.

Agreed.
 
> The group of the pins could be configured for the function provided 
> by the SoC, such as general purpose I/O or specific function such as
> ethernet depending on what products or boards you design for various 
> customers or vendors. Thanks for device tree introducing, it is easy 
> to find what resources the board needs including the pins usage is 
> also defined here.

All clear. However, if the ethernet driver has loaded, it means the
device tree says the ethernet should be loaded, unless it happens to
be on some discoverable bus. And so the device tree node for the
ethernet should also contain the needed pinctrl properties.  The core
driver code should of seen these properties and already enabled the
correct pinctrl state before the driver probes.

This is how every other driver works. Like i said, i don't think i've
seen any other driver do its own pinctrl. So i just need a simple
description, what is different here, why does this driver need to do
it, when no other does?

    Andrew
