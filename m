From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v2 1/2] net: macb: Check DMA mappings for error
Date: Fri, 28 Feb 2014 16:24:20 -0800
Message-ID: <fd021c95-4388-4945-a0b6-fe6acf0c8be6@CH1EHSMHS014.ehs.local>
References: <1393538285-28297-1-git-send-email-soren.brinkmann@xilinx.com>
 <1393545459.14067.79.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Vinod Koul <vinod.koul@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1393545459.14067.79.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

On Thu, 2014-02-27 at 11:57PM +0000, Ben Hutchings wrote:
> On Thu, 2014-02-27 at 13:58 -0800, Soren Brinkmann wrote:
> [...]
> > diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethe=
rnet/cadence/macb.c
> > index 3190d38e16fb..a9c2ccfc1740 100644
> > --- a/drivers/net/ethernet/cadence/macb.c
> > +++ b/drivers/net/ethernet/cadence/macb.c
> > @@ -632,11 +632,16 @@ static void gem_rx_refill(struct macb *bp)
> >  					   "Unable to allocate sk_buff\n");
> >  				break;
> >  			}
> > -			bp->rx_skbuff[entry] =3D skb;
> > =20
> >  			/* now fill corresponding descriptor entry */
> >  			paddr =3D dma_map_single(&bp->pdev->dev, skb->data,
> >  					       bp->rx_buffer_size, DMA_FROM_DEVICE);
> > +			if (dma_mapping_error(&bp->pdev->dev, paddr)) {
> > +				dev_kfree_skb(skb);
> > +				break;
> > +			}
> > +
> > +			bp->rx_skbuff[entry] =3D skb;
> > =20
> >  			if (entry =3D=3D RX_RING_SIZE - 1)
> >  				paddr |=3D MACB_BIT(RX_WRAP);
> > @@ -1040,6 +1045,10 @@ static int macb_start_xmit(struct sk_buff *s=
kb, struct net_device *dev)
>=20
> A bit more context:
>=20
> 	entry =3D macb_tx_ring_wrap(bp->tx_head);
> 	bp->tx_head++;
>=20
> >  	netdev_vdbg(bp->dev, "Allocated ring entry %u\n", entry);
> >  	mapping =3D dma_map_single(&bp->pdev->dev, skb->data,
> >  				 len, DMA_TO_DEVICE);
> > +	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
> > +		kfree_skb(skb);
> > +		goto unlock;
> > +	}
>=20
> You need to move the bp->tx_head increment below this error check.
> Sorry I didn't spot this the first time.

No problem. I'll wait till next week with a re-spin, in case somebody
else has comments.

	S=C3=B6ren
