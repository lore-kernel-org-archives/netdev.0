From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Thu, 13 Oct 2016 10:24:32 -0400 (EDT)
Message-ID: <20161013.102432.1450901395774429343.davem@davemloft.net>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Tue, 11 Oct 2016 19:15:44 +0200

> After the commit 9207f9d45b0a ("net: preserve IP control block
> during GSO segmentation"), the GSO CB and the IPoIB CB conflict.
> That destroy the IPoIB address information cached there,
> causing a severe performance regression, as better described here:
> 
> http://marc.info/?l=linux-kernel&m=146787279825501&w=2
> 
> This change moves the data cached by the IPoIB driver from the
> skb control lock into the IPoIB hard header, as done before
> the commit 936d7de3d736 ("IPoIB: Stop lying about hard_header_len
> and use skb->cb to stash LL addresses").
> In order to avoid GRO issue, on packet reception, the IPoIB driver
> stash into the skb a dummy pseudo header, so that the received
> packets have actually a hard header matching the declared length.
> Also the connected mode maximum mtu is reduced by 16 bytes to
> cope with the increased hard header len.
> 
> After this commit, IPoIB performances are back to pre-regression
> value.
> 
> Fixes: 9207f9d45b0a ("net: preserve IP control block during GSO segmentation")
> Signed-off-by: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Not providing an accurate hard_header_len causes many problems.

In fact we recently fixed the mlxsw driver to stop doing this.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
