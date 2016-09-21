From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next 6/7] net/faraday: Fix phy link irq on Aspeed G5
 SoCs
Date: Wed, 21 Sep 2016 20:43:08 +1000
Message-ID: <1474454588.2857.124.camel@kernel.crashing.org>
References: <20160920063007.24291-1-joel@jms.id.au>
         <20160920063007.24291-7-joel@jms.id.au>
         <1474373594.2857.62.camel@kernel.crashing.org>
         <20160920152940.GI22292@lunn.ch>
         <CACPK8Xde3COqQ8euhj3Ww5pPiAn4iXvMqJVpjKu3eGa1Pm=1GA@mail.gmail.com>
         <1474448633.2857.119.camel@kernel.crashing.org>
         <CACPK8Xf7vTG8z-81i74E3nj2PPZOW8ZQuneCfnNrz0Kcyo6PHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net,
        Gavin Shan <gwshan@linux.vnet.ibm.com>,
        Andrew Jeffery <andrew@aj.id.au>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joel Stanley <joel@jms.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACPK8Xf7vTG8z-81i74E3nj2PPZOW8ZQuneCfnNrz0Kcyo6PHA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-09-21 at 18:48 +0930, Joel Stanley wrote:
> > What line is it out of the PHY ? The PHY IRQ ? If yes then it's meant
> > to be telling you to go look at the PHY registers for a link status
> > change, but only works if the PHY has also been configured
> > appropriately...
> 
> Yep, PHY IRQ.
> 
> > Mostly we ignore those things in Linux and just poll the PHY.
> 
> That's simpler. It's what we're doing on Aspeed systems when using NSCI already.
> 
> The driver is already polling the PHY, I propose we mask out this
> interrupt for all systems. I gave that a run on my ast2500evb and it
> behaved itself.

Right it's the easiest way.

If we want to use interrupts without polling in order to maybe
insignificantly reduce the load in the system, we should then make sure
we configure the IRQ with a matching polarity between the PHY and the
NIC *and* in a way that matches the pull up/down's on the board.

The above is possible but tricky as all the parts have to be right, and
the IRQ configuration of PHYs is basically PHY model specific.

So I'd start with just masking it out.

Cheers,
Ben.
