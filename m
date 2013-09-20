From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] skge: fix broken driver
Date: Fri, 20 Sep 2013 07:36:41 -0700
Message-ID: <20130920073641.7b279f21@samsung-9>
References: <alpine.LRH.2.02.1309191409301.12162@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Vasiliy Glazov <vascom2@gmail.com>
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:58088 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598Ab3ITOgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 10:36:49 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so463469pdi.27
        for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 07:36:48 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.02.1309191409301.12162@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Sep 2013 14:13:17 -0400 (EDT)
Mikulas Patocka <mpatocka@redhat.com> wrote:

> The patch 136d8f377e1575463b47840bc5f1b22d94bf8f63 broke the skge driver.
> Note this part of the patch:
> +               if (skge_rx_setup(skge, e, nskb, skge->rx_buf_size) < 0) {
> +                       dev_kfree_skb(nskb);
> +                       goto resubmit;
> +               }
> +
>                 pci_unmap_single(skge->hw->pdev,
>                                  dma_unmap_addr(e, mapaddr),
>                                  dma_unmap_len(e, maplen),
>                                  PCI_DMA_FROMDEVICE);
>                 skb = e->skb;
>                 prefetch(skb->data);
> -               skge_rx_setup(skge, e, nskb, skge->rx_buf_size);
> 
> The function skge_rx_setup modifies e->skb to point to the new skb. Thus,
> after this change, the new buffer, not the old, is returned to the
> networking stack.
> 
> This bug is present in kernels 3.11, 3.11.1 and 3.12-rc1. The patch should 
> be queued for 3.11-stable.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: Vasiliy Glazov <vascom2@gmail.com>
> Tested-by: Mikulas Patocka <mpatocka@redhat.com>
> 

Thanks for fixing this. Maybe I should go on vacation more often.
