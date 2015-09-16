From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 1/4] stmmac: replace all pr_xxx by their dev_xxx
 counterpart
Date: Wed, 16 Sep 2015 09:35:39 +0200
Message-ID: <20150916073539.GA11061@Red>
References: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
 <1441815282.17219.51.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1441815282.17219.51.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 09, 2015 at 09:14:42AM -0700, Joe Perches wrote:
> On Wed, 2015-09-09 at 15:14 +0200, LABBE Corentin wrote:
> > The stmmac driver use lots of pr_xxx functions to print information.
> > This is bad since we cannot know which device logs the information.
> > (moreover if two stmmac device are present)
> []
> > So this patch replace all pr_xxx by their dev_xxx counterpart.
> 
> Using
> 	netdev_<level>(priv->dev, ...
> instead of
> 	dev_<level>(priv->device,
> 
> would be more consistent with other ethernet devices.
> 
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> []
> > @@ -298,7 +298,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
> >  			 */
> >  			spin_lock_irqsave(&priv->lock, flags);
> >  			if (priv->eee_active) {
> > -				pr_debug("stmmac: disable EEE\n");
> > +				dev_dbg(priv->device, "disable EEE\n");
> 
> 				netdev_dbg(priv->dev, ...)
> 
> > @@ -657,10 +657,10 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
> >  		priv->adv_ts = 1;
> >  
> >  	if (netif_msg_hw(priv) && priv->dma_cap.time_stamp)
> > -		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
> > +		dev_dbg(priv->device, "IEEE 1588-2002 Time Stamp supported\n");
> 
> And these netif_msg_<foo> could be
> 
> 	if (priv->dma_cap.timestamp)
> 		netif_dbg(priv, hw, priv->dev, ...);
> 
> 

Hello

My main goal is to improve logging from
[    0.796804] stmmaceth 1c50000.ethernet: no reset control found
[    0.802635]  Ring mode enabled
[    0.805713]  No HW DMA feature register supported
[    0.810239]  Normal descriptors
[    0.813577]  TX Checksum insertion supported
[   23.615074] eth0: device MAC address aa:65:84:d5:a3:58
[   23.704326]  RX IPC Checksum Offload disabled
[   23.704349]  No MAC Management Counters available

to that:
[    0.788147] sun7i-dwmac 1c50000.ethernet (unnamed net_device) (uninitialized): no reset control found
[    0.797400] sun7i-dwmac 1c50000.ethernet (unnamed net_device) (uninitialized): Ring mode enabled
[    0.806211] sun7i-dwmac 1c50000.ethernet (unnamed net_device) (uninitialized): No HW DMA feature register supported
[    0.816658] sun7i-dwmac 1c50000.ethernet (unnamed net_device) (uninitialized): Normal descriptors
[    0.825522] sun7i-dwmac 1c50000.ethernet (unnamed net_device) (uninitialized): TX Checksum insertion supported
[   12.971725] sun7i-dwmac 1c50000.ethernet eth0: device MAC address 3e:62:18:6f:c7:f4
[   13.056902] sun7i-dwmac 1c50000.ethernet eth0: RX IPC Checksum Offload disabled
[   13.056929] sun7i-dwmac 1c50000.ethernet eth0: No MAC Management Counters available

But by using the netdev_ functions the first five lines are not "pretty" with the "(unnamed net_device) (uninitialized)"
Could I switch back do dev_xxx since they are "early device logging" and so make it prettier ?

Best regards
