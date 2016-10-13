From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: Trigger state machine on state
 change and not polling.
Date: Thu, 13 Oct 2016 12:04:38 -0400 (EDT)
Message-ID: <20161013.120438.1184858529653754916.davem@davemloft.net>
References: <1476303294-14944-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, kyle.roeschley@ni.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755744AbcJMQFq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 12:05:46 -0400
In-Reply-To: <1476303294-14944-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 12 Oct 2016 22:14:53 +0200

> The phy_start() is used to indicate the PHY is now ready to do its
> work. The state is changed, normally to PHY_UP which means that both
> the MAC and the PHY are ready.
> 
> If the phy driver is using polling, when the next poll happens, the
> state machine notices the PHY is now in PHY_UP, and kicks off
> auto-negotiation, if needed.
> 
> If however, the PHY is using interrupts, there is no polling. The phy
> is stuck in PHY_UP until the next interrupt comes along. And there is
> no reason for the PHY to interrupt.
> 
> Have phy_start() schedule the state machine to run, which both speeds
> up the polling use case, and makes the interrupt use case actually
> work.
> 
> This problems exists whenever there is a state change which will not
> cause an interrupt. Trigger the state machine in these cases,
> e.g. phy_error().
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Cc: Kyle Roeschley <kyle.roeschley@ni.com>
> ---
> 
> This should be applied to stable, but i've no idea what fixes: tag to
> use. It could be phylib has been broken since interrupts were added?

Since you think it should go to -stable, it is not appropriate to target
this patch to 'net-next', only 'net' makes sense.

Therefore I applied this to 'net' and will queue it up for -stable.

Personally I think phylib was broken in this area since interrupts
were added.
