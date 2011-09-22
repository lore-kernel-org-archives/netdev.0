From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: RE: [Pv-drivers] [PATCH 14/14] vmxnet3: convert to SKB paged frag
 API.
Date: Thu, 22 Sep 2011 17:46:33 +0100
Message-ID: <1316709993.23371.81.camel@zakaz.uk.xensource.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
	 <1316678008-16842-14-git-send-email-ian.campbell@citrix.com>
	 <B07832953588294D802727FF264E276A13EB817FBD@exch-mbx-112.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: Bhavesh Davda <bhavesh@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:61438 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717Ab1IVQqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 12:46:34 -0400
In-Reply-To: <B07832953588294D802727FF264E276A13EB817FBD@exch-mbx-112.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-22 at 17:30 +0100, Bhavesh Davda wrote:
> These changes look sane. What about frag->page_offset and frag->size, are there APIs to access those as well?

You can go at those directly.

The important part here is to abstract away the access to the ->page
variable so we can change how the reference counting works.

So unless people think there is a compelling reason to hide away size
and offset I wasn't planning on doing anything like that.

Ian.

> 
> [sorry can't pull from git.kernel.org at the moment to answer my own quesion]
> 
> - Bhavesh
>  
> Bhavesh P. Davda
> 
> > -----Original Message-----
> > From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-bounces@vmware.com] On
> > Behalf Of Ian Campbell
> > Sent: Thursday, September 22, 2011 12:53 AM
> > To: netdev@vger.kernel.org
> > Cc: VMware, Inc.; Ian Campbell
> > Subject: [Pv-drivers] [PATCH 14/14] vmxnet3: convert to SKB paged frag API.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
> > Cc: "VMware, Inc." <pv-drivers@vmware.com>
> > Cc: netdev@vger.kernel.org
> > ---
> >  drivers/net/vmxnet3/vmxnet3_drv.c |    8 ++++----
> >  1 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> > b/drivers/net/vmxnet3/vmxnet3_drv.c
> > index 759c1a4..57e7c66 100644
> > --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> > +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> > @@ -654,7 +654,7 @@ vmxnet3_append_frag(struct sk_buff *skb, struct
> > Vmxnet3_RxCompDesc *rcd,
> > 
> >  	BUG_ON(skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS);
> > 
> > -	frag->page = rbi->page;
> > +	__skb_frag_set_page(frag, rbi->page);
> >  	frag->page_offset = 0;
> >  	frag->size = rcd->len;
> >  	skb->data_len += frag->size;
> > @@ -748,9 +748,9 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx
> > *ctx,
> > 
> >  		tbi = tq->buf_info + tq->tx_ring.next2fill;
> >  		tbi->map_type = VMXNET3_MAP_PAGE;
> > -		tbi->dma_addr = pci_map_page(adapter->pdev, frag->page,
> > -					     frag->page_offset, frag->size,
> > -					     PCI_DMA_TODEVICE);
> > +		tbi->dma_addr = skb_frag_dma_map(&adapter->pdev->dev, frag,
> > +						 0, frag->size,
> > +						 PCI_DMA_TODEVICE);
> > 
> >  		tbi->len = frag->size;
> > 
> > --
> > 1.7.2.5
> > 
> > _______________________________________________
> > Pv-drivers mailing list
> > Pv-drivers@vmware.com
> > http://mailman2.vmware.com/mailman/listinfo/pv-drivers
