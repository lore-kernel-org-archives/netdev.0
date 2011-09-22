From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [PATCH 14/14] vmxnet3: convert to SKB paged frag
 API.
Date: Thu, 22 Sep 2011 09:30:03 -0700
Message-ID: <B07832953588294D802727FF264E276A13EB817FBD@exch-mbx-112.vmware.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
 <1316678008-16842-14-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "VMware, Inc." <pv-drivers@vmware.com>
To: Ian Campbell <ian.campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:46747 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750874Ab1IVQ3q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 12:29:46 -0400
In-Reply-To: <1316678008-16842-14-git-send-email-ian.campbell@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes look sane. What about frag->page_offset and frag->size, are there APIs to access those as well?

[sorry can't pull from git.kernel.org at the moment to answer my own quesion]

- Bhavesh
 
Bhavesh P. Davda

> -----Original Message-----
> From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-bounces@vmware.com] On
> Behalf Of Ian Campbell
> Sent: Thursday, September 22, 2011 12:53 AM
> To: netdev@vger.kernel.org
> Cc: VMware, Inc.; Ian Campbell
> Subject: [Pv-drivers] [PATCH 14/14] vmxnet3: convert to SKB paged frag API.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
> Cc: "VMware, Inc." <pv-drivers@vmware.com>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 759c1a4..57e7c66 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -654,7 +654,7 @@ vmxnet3_append_frag(struct sk_buff *skb, struct
> Vmxnet3_RxCompDesc *rcd,
> 
>  	BUG_ON(skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS);
> 
> -	frag->page = rbi->page;
> +	__skb_frag_set_page(frag, rbi->page);
>  	frag->page_offset = 0;
>  	frag->size = rcd->len;
>  	skb->data_len += frag->size;
> @@ -748,9 +748,9 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx
> *ctx,
> 
>  		tbi = tq->buf_info + tq->tx_ring.next2fill;
>  		tbi->map_type = VMXNET3_MAP_PAGE;
> -		tbi->dma_addr = pci_map_page(adapter->pdev, frag->page,
> -					     frag->page_offset, frag->size,
> -					     PCI_DMA_TODEVICE);
> +		tbi->dma_addr = skb_frag_dma_map(&adapter->pdev->dev, frag,
> +						 0, frag->size,
> +						 PCI_DMA_TODEVICE);
> 
>  		tbi->len = frag->size;
> 
> --
> 1.7.2.5
> 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
