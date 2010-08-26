From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [IPoIB] Identify multicast packets and fix IGMP breakage V2
Date: Thu, 26 Aug 2010 16:21:46 -0600
Message-ID: <20100826222146.GA23025@obsidianresearch.com>
References: <adapqx5rtez.fsf@cisco.com> <alpine.DEB.2.00.1008261613160.24174@router.home> <alpine.DEB.2.00.1008261629440.24174@router.home> <20100826.151553.242147157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org, yosefe-smomgflXvOZWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100826.151553.242147157.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 26, 2010 at 03:15:53PM -0700, David Miller wrote:
> From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
> Date: Thu, 26 Aug 2010 16:31:14 -0500 (CDT)
> 
> > @@ -271,6 +271,13 @@ static void ipoib_ib_handle_rx_wc(struct
> >  	ipoib_ud_dma_unmap_rx(priv, mapping);
> >  	ipoib_ud_skb_put_frags(priv, skb, wc->byte_len);
> > 
> > +	if ((wc->wc_flags & IB_WC_GRH) &&
> > +		IN6_IS_ADDR_MULTICAST(&((struct ipv6hdr *)skb->data)->daddr))
> > +
> > +		skb->pkt_type = PACKET_MULTICAST;
> > +	else
> > +		skb->pkt_type = PACKET_HOST;
> 
> I really don't think you can assume there is an ipv6 header here
> at all.

The 40 bytes at this location are defined by the HW specification to
be an IB GRH which has an identical layout to an IPv6 header. Roland
is right, it would be clearer to use ib_grh ->dgid

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
