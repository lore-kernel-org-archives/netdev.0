From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: e1000 driver 2.6.18 - how to waste processor cycles
Date: Wed, 8 Nov 2006 17:01:44 -0800
Message-ID: <4807377b0611081701i26ee7ce0k1f822dbbe52c2c8@mail.gmail.com>
References: <45524E3A.7080301@soleranetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux kernel" <linux-kernel@vger.kernel.org>,
	"NetDEV list" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:49822 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1422893AbWKIBBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 20:01:46 -0500
Received: by ug-out-1314.google.com with SMTP id m3so78543ugc
        for <netdev@vger.kernel.org>; Wed, 08 Nov 2006 17:01:44 -0800 (PST)
To: "Jeff V. Merkey" <jmerkey@soleranetworks.com>
In-Reply-To: <45524E3A.7080301@soleranetworks.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

included netdev...

On 11/8/06, Jeff V. Merkey <jmerkey@soleranetworks.com> wrote:
>
> Is there a good reason the skb refill routine in e1000_alloc_rx_buffers
> needs to go and touch and remap skb memory
> on already loaded descriptors/  This seems extremely wasteful of
> processor cycles when refilling the ring buffer.
>
> I note that the archtiecture has changed and is recycling buffers from
> the rx_irq routine and when the routine is called
> to refill the ring buffers, a lot of wasteful and needless calls for
> map_skb is occurring.

we have to unmap the descriptor (or at least do
pci_dma_sync_single_for_cpu / pci_dma_sync_single_for_device) because
the dma API says we can't be guaranteed the cacheable memory is
consistent until we do one of the afore mentioned pci dma ops.

we have to do *something* before we access it.  Simplest path is to
unmap it and then recycle/map it.

If you can show that it is faster to use pci_dma_sync_single_for_cpu
and friends I'd be glad to take a patch.

Hope this helps,
  Jesse
