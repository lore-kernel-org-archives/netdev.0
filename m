From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: phy: Trigger state machine on state change
 and not polling.
Date: Thu, 13 Oct 2016 18:29:01 +0200
Message-ID: <20161013162901.GA1286@lunn.ch>
References: <1476303294-14944-1-git-send-email-andrew@lunn.ch>
 <20161013.120438.1184858529653754916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, kyle.roeschley@ni.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44889 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756897AbcJMQaE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 12:30:04 -0400
Content-Disposition: inline
In-Reply-To: <20161013.120438.1184858529653754916.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, Oct 13, 2016 at 12:04:38PM -0400, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Wed, 12 Oct 2016 22:14:53 +0200
> 
> > The phy_start() is used to indicate the PHY is now ready to do its
> > work. The state is changed, normally to PHY_UP which means that both
> > the MAC and the PHY are ready.
> > 
> > If the phy driver is using polling, when the next poll happens, the
> > state machine notices the PHY is now in PHY_UP, and kicks off
> > auto-negotiation, if needed.
> > 
> > If however, the PHY is using interrupts, there is no polling. The phy
> > is stuck in PHY_UP until the next interrupt comes along. And there is
> > no reason for the PHY to interrupt.
> > 
> > Have phy_start() schedule the state machine to run, which both speeds
> > up the polling use case, and makes the interrupt use case actually
> > work.
> > 
> > This problems exists whenever there is a state change which will not
> > cause an interrupt. Trigger the state machine in these cases,
> > e.g. phy_error().
> > 
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > Cc: Kyle Roeschley <kyle.roeschley@ni.com>
> > ---
> > 
> > This should be applied to stable, but i've no idea what fixes: tag to
> > use. It could be phylib has been broken since interrupts were added?
> 
> Since you think it should go to -stable, it is not appropriate to target
> this patch to 'net-next', only 'net' makes sense.

Hi David

Just for my clarification:

We are in the middle of the merge window. What does net-next and net
mean at the moment?

Outside of the merge window, net is patches being collected to go into
the next -rc. net-next is used to collect patches for the next merge
window.

During the merge window, i've seen you collect patches into net-next
and send additional pull requests to Linus. Which is why i based it on
net-next. I did not check, but i assumed net was still on v4.8.0,
waiting for -rc1 to come out. But this assumption seems untrue. During
the merge window does net equate to what Linus has already pulled from
net-next?

Thanks
	Andrew
