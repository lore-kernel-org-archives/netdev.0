From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 3/9] e1000 driver conversion
Date: Tue, 08 Aug 2006 22:59:14 +0200
Message-ID: <1155070755.23134.26.camel@lappy>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	 <20060808193355.1396.71047.sendpatchset@lappy> <44D8F919.7000006@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:33049 "EHLO
	amsfep18-int.chello.nl") by vger.kernel.org with ESMTP
	id S1030273AbWHHVPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 17:15:37 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44D8F919.7000006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 13:50 -0700, Auke Kok wrote:
> Peter Zijlstra wrote:
> > Update the driver to make use of the NETIF_F_MEMALLOC feature.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Signed-off-by: Daniel Phillips <phillips@google.com>
> > 
> > ---
> >  drivers/net/e1000/e1000_main.c |   11 +++++------
> >  1 file changed, 5 insertions(+), 6 deletions(-)
> > 
> > Index: linux-2.6/drivers/net/e1000/e1000_main.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> > +++ linux-2.6/drivers/net/e1000/e1000_main.c
> > @@ -4020,8 +4020,6 @@ e1000_alloc_rx_buffers(struct e1000_adap
> >  		 */
> >  		skb_reserve(skb, NET_IP_ALIGN);
> >  
> > -		skb->dev = netdev;
> > -
> >  		buffer_info->skb = skb;
> >  		buffer_info->length = adapter->rx_buffer_len;
> >  map_skb:
> > @@ -4135,8 +4136,6 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
> >  		 */
> >  		skb_reserve(skb, NET_IP_ALIGN);
> >  
> > -		skb->dev = netdev;
> > -
> >  		buffer_info->skb = skb;
> >  		buffer_info->length = adapter->rx_ps_bsize0;
> >  		buffer_info->dma = pci_map_single(pdev, skb->data,
> > -
> 
> can we really delete these??

The new {,__}netdev_alloc_skb() will set it when the allocation
succeeds.

