From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/7] net/faraday: Fix phy link irq on Aspeed G5
 SoCs
Date: Tue, 20 Sep 2016 17:29:40 +0200
Message-ID: <20160920152940.GI22292@lunn.ch>
References: <20160920063007.24291-1-joel@jms.id.au>
 <20160920063007.24291-7-joel@jms.id.au>
 <1474373594.2857.62.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Joel Stanley <joel@jms.id.au>, davem@davemloft.net,
        gwshan@linux.vnet.ibm.com, andrew@aj.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474373594.2857.62.camel@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2016 at 10:13:14PM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2016-09-20 at 16:00 +0930, Joel Stanley wrote:
> > On Aspeed SoC with a direct PHY connection (non-NSCI), we receive
> > continual PHYSTS interrupts:
> > 
> >  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
> >  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
> >  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
> >  [   20.300000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
> > 
> > This is because the driver was enabling low-level sensitive interrupt
> > generation where the systems are wired for high-level. All CPU cycles
> > are spent servicing this interrupt.
> 
> If this is a system wiring issue, should it be represented by a DT
> property ?

Is there a device tree binding document somewhere?

Is it possible just to put ACTIVE_HIGH in the right place in the
binding?

	Andrew
