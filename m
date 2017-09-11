From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/3] net: ethernet: socionext: add AVE ethernet
 driver
Date: Mon, 11 Sep 2017 14:00:09 +0200
Message-ID: <20170911120009.GA24174@lunn.ch>
References: <1504875731-3680-3-git-send-email-hayashi.kunihiko@socionext.com>
 <20170908135030.GA25219@lunn.ch>
 <20170911155047.6717.4A936039@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>,
 Masami Hiramatsu <masami.hiramatsu@linaro.org>,
 Jassi Brar <jaswinder.singh@linaro.org>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Masahiro Yamada <yamada.masahiro@socionext.com>,
 Rob Herring <robh+dt@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20170911155047.6717.4A936039@socionext.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> > > +static irqreturn_t ave_interrupt(int irq, void *netdev)
> > > +{
> > > +	struct net_device *ndev = (struct net_device *)netdev;
> > > +	struct ave_private *priv = netdev_priv(ndev);
> > > +	u32 gimr_val, gisr_val;
> > > +
> > > +	gimr_val = ave_irq_disable_all(ndev);
> > > +
> > > +	/* get interrupt status */
> > > +	gisr_val = ave_r32(ndev, AVE_GISR);
> > > +
> > > +	/* PHY */
> > > +	if (gisr_val & AVE_GI_PHY) {
> > > +		ave_w32(ndev, AVE_GISR, AVE_GI_PHY);
> > > +		if (priv->internal_phy_interrupt)
> > > +			phy_mac_interrupt(ndev->phydev, ndev->phydev->link);
> > 
> > Humm. I don't think this is correct. You are supposed to give it the
> > new link state, not the old.
> > 
> > What does a PHY interrupt mean here? 
> 
> In the general case, I think PHY events like changing link state are transmitted
> to CPU as interrupt via interrupt controller, then PHY driver itself can handle
> the interrupt.
> 
> And in this case, PHY events are transmitted to MAC as one of its interrupt factor,
> then I thought that MAC driver had to tell the events to PHY.

Could this be in-band SGMI signalling from the PHY to the MAC? Does
the documentation give examples of when this interrupt will happen?

    Andrew
