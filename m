From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: [PATCH] net: mv643xx_eth: fix DT port device name
Date: Mon, 8 Jul 2013 00:05:40 +0200
Message-ID: <20130708000540.00004b37@unknown>
References: <1373229231-8838-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<20130707234341.0000721b@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130707234341.0000721b@unknown>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 7 Jul 2013 23:43:41 +0200
Jonas Gorski <jogo@openwrt.org> wrote:

> On Sun,  7 Jul 2013 22:33:51 +0200
> Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> wrote:
> 
> > Device tree support added to Marvell MV643xx ethernet driver registers
> > port devices from port device nodes found on the corresponding controller
> > node. The current port device name will cause the second controller to
> > fail on registration because of two identical device names. This fixes
> > the issue by taking the device node's name also as port device name.
> > 
> > Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> > Reported-by: Jonas Gorski <jogo@openwrt.org>
> > ---
> > Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> > Cc: Jonas Gorski <jogo@openwrt.org>
> > Cc: netdev@vger.kernel.org
> > Cc: linux-arm-kernel@lists.infradead.org
> > Cc: linux-kernel@vger.kernel.org
> > ---
> >  drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> > index 6495bea..1f3a03d 100644
> > --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> > +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> > @@ -2521,7 +2521,7 @@ static int mv643xx_eth_shared_of_add_port(struct platform_device *pdev,
> >  		of_property_read_u32(pnp, "duplex", &ppd.duplex);
> >  	}
> >  
> > -	ppdev = platform_device_alloc(MV643XX_ETH_NAME, ppd.port_number);
> > +	ppdev = platform_device_alloc(pnp->name, ppd.port_number);
> >  	if (!ppdev)
> >  		return -ENOMEM;
> >  	ppdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
> 
> This breaks ethernet completely, as there is no platform driver
> registered for pnp->name ("ethernetX-port"), only for MV643XX_ETH_NAME.

Looking back at our conversation, this is my fault.
I actually did not change this part as you asked, but I saw the
alloc/del issue with port 0, then added the counter and also only
replaced the ppd.port_number in the alloc with it. I had completely
forgotten at that time to replace the device name; else I would
have caught it back then.

I only caught it now because I tried your patch and wondered why there
wasn't anything registered, not because I saw the problem by review.

Sorry for that.

Regards
Jonas
