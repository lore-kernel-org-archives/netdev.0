From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: NET_DMA: where do we ever call dma_skb_copy_datagram_iovec() with NULL pinned_list?
Date: Tue, 24 Jul 2007 10:24:54 -0700
Message-ID: <c0a09e5c0707241024p3533df25h5e8dc904d0e0778f@mail.gmail.com>
References: <20070721034829.GL21668@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christopher.leech@intel.com
To: "Al Viro" <viro@ftp.linux.org.uk>, shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.238]:30746 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757558AbXGXRY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 13:24:59 -0400
Received: by qb-out-0506.google.com with SMTP id e11so2655366qbe
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 10:24:58 -0700 (PDT)
In-Reply-To: <20070721034829.GL21668@ftp.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/20/07, Al Viro <viro@ftp.linux.org.uk> wrote:
>         AFAICS, all callers of dma_skb_copy_datagram_iovec()
> are either
>         * recursive for fragments, pass pinned_list unchanged or
>         * called from tcp, with pinned_list coming from
> tp->ucopy.pinned_list and only when tp->ucopy.dma_chan is non-NULL.
>
> Now, all non-NULL assignments to ->dma_chan have the same form:
>         if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
>                 tp->ucopy.dma_chan = get_softnet_dma();
> IOW, if ->ucopy.pinned_list stays NULL, ->ucopy.dma_chan will do the same.
>
> Moreover, any place that resets ->ucopy.pinned_list will also reset
> ->ucopy.dma_chan.
>
> IOW, we can't ever get non-NULL tp->ucopy.dma_chan while tp->ucopy.pinned_list
> is NULL.  So how can we ever get to the dma_memcpy_to_kernel_iovec()?

Shannon what do you think? Is this a bug, or does it no longer support
non-userspace iovecs?

Thanks -- Andy
