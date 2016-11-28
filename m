From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] stmmac ethernet: remove cut & paste code
Date: Mon, 28 Nov 2016 08:03:52 -0800
Message-ID: <1480349032.17012.1.camel@perches.com>
References: <20161124085506.GA25007@amd> <20161124102901.GA27793@amd>
         <20161124103630.GB27793@amd> <20161124104619.GA30723@amd>
         <20161124110548.GB30723@amd> <1480017925.19726.13.camel@perches.com>
         <20161124214401.GA25662@amd> <1480026433.19726.17.camel@perches.com>
         <20161128115023.GA15034@amd> <1480343068.14294.5.camel@perches.com>
         <20161128143539.GB31224@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        ezequiel@vanguardiasur.com.ar, sonic.zhang@analog.com,
        fabrice.gasnier@st.com
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128143539.GB31224@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-11-28 at 15:35 +0100, Pavel Machek wrote:
> On Mon 2016-11-28 06:24:28, Joe Perches wrote:
> > On Mon, 2016-11-28 at 12:50 +0100, Pavel Machek wrote:
> > > On Thu 2016-11-24 14:27:13, Joe Perches wrote:
> > > > On Thu, 2016-11-24 at 22:44 +0100, Pavel Machek wrote:
> > > > > On Thu 2016-11-24 12:05:25, Joe Perches wrote:
> > > > > > On Thu, 2016-11-24 at 12:05 +0100, Pavel Machek wrote:
> > > > > > > Remove duplicate code from _tx routines.
> > > > > > 
> > > > > > trivia:
> > > > > > 
> > > > > > > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > > > > > 
> > > > > > []
> > > > > > > @@ -1960,6 +1960,38 @@ static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
> > > > > > >  	}
> > > > > > >  }
> > > > > > >  
> > > > > > > +static void stmmac_xmit_common(struct sk_buff *skb, struct net_device *dev, int nfrags, struct dma_desc *desc)
> > > > > > > +{
> > > > > > > +	struct stmmac_priv *priv = netdev_priv(dev);
> > > > > > > +
> > > > > > > +	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
> > > > > > > +		if (netif_msg_hw(priv))
> > > > > > > +			pr_debug("%s: stop transmitted packets\n", __func__);
> > > > > > 
> > > > > > 		netif_dbg(priv, hw, dev, "%s: stop transmitted packets\n",
> > > > > > 			  __func__);
> > > > > 
> > > > > Not now. Modifying the code while de-duplicating would be bad idea.
> > > > 
> > > > Too many people think overly granular patches are the
> > > > best and only way to make changes.
> > > > Deduplication and consolidation can happen simultaneously.
> > > 
> > > Can, but should not at this point. Please take a look at the driver in
> > > question before commenting on trivial printk style.
> > 
> > I had.
> > 
> > It's perfectly acceptable and already uses netif_<level> properly.
> > 
> > This consolidation now introduces the _only_ instance where it is
> > now improperly using a netif_msg_<type> then single pr_<level>
> > function sequence that should be consolidated into netif_dbg.
> > Every other use of netif_msg_<level> then either emits multiple
> > lines or is used in an if/else.
> 
> Are you looking at right driver?

Yes and I think you should make changes against -next
and not Linus' where this is:

b3e51069627e2 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c (LABBE Corentin            2016-11-16 20:09:41 +0100  755)                              netif_warn(priv, link, priv->dev,
b3e51069627e2 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c (LABBE Corentin            2016-11-16 20:09:41 +0100  756)                                         "Speed (%d) not 10/100\n",
b3e51069627e2 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c (LABBE Corentin            2016-11-16 20:09:41 +0100  757)                                         phydev->speed);

>  I don't see single use of
> netif_msg_<level>, but see this at stmmac_main.c:756. Code is actually
> pretty consistent using pr_*.
> 
>                                 if (netif_msg_link(priv))
>                                         pr_warn("%s: Speed (%d) not 10/100\n",
>                                                 dev->name, phydev->speed);
> 
> Anyway, I'm moving code around, if you want to do trivial cleanups, do
> them yourself.

cheers, Joe
