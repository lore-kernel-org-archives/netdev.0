From: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
Subject: Re: [PATCH] net: ethernet: cpsw: fix usage of
 cpdma_check_free_tx_desc()
Date: Tue, 12 Mar 2013 21:20:27 +0100
Message-ID: <20130312202027.GA935@blumentopf>
References: <1363105879-26921-1-git-send-email-zonque@gmail.com>
 <513F8660.2010602@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <zonque@gmail.com>, netdev@vger.kernel.org,
	andreas.fenkart@streamunlimited.com, davem@davemloft.net,
	s.neumann@raumfeld.com, koen@dominion.thruhere.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:53381 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932514Ab3CLUdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 16:33:10 -0400
Received: from mailout-de.gmx.net ([10.1.76.27]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0M4UOQ-1UyXlD16BY-00yj64 for
 <netdev@vger.kernel.org>; Tue, 12 Mar 2013 21:20:31 +0100
Content-Disposition: inline
In-Reply-To: <513F8660.2010602@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 01:17:44AM +0530, Mugunthan V N wrote:
> On 3/12/2013 10:01 PM, Daniel Mack wrote:
> >Commit fae50823d0 ("net: ethernet: davinci_cpdma: Add boundary for rx
> >and tx descriptors") introduced a function to check the current
> >allocation state of tx packets. The return value is taken into account
> >to stop the netqork queue on the adapter in case there are no free
> >slots.
> >
> >However, cpdma_check_free_tx_desc() returns 'true' if there is room in
> >the bitmap, not 'false', so the usage of the function is wrong.
> >
> >Signed-off-by: Daniel Mack <zonque@gmail.com>
> >Cc: Mugunthan V N <mugunthanvnm@ti.com>
> >Reported-by: Sven Neumann <s.neumann@raumfeld.com>
> >Reported-by: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
> >---
> >  drivers/net/ethernet/ti/cpsw.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> >index 01ffbc4..75c4855 100644
> >--- a/drivers/net/ethernet/ti/cpsw.c
> >+++ b/drivers/net/ethernet/ti/cpsw.c
> >@@ -905,7 +905,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
> >  	/* If there is no more tx desc left free then we need to
> >  	 * tell the kernel to stop sending us tx frames.
> >  	 */
> >-	if (unlikely(cpdma_check_free_tx_desc(priv->txch)))
> >+	if (unlikely(!cpdma_check_free_tx_desc(priv->txch)))
> >  		netif_stop_queue(ndev);
> >  	return NETDEV_TX_OK;
> Tested-by: Mugunthan V N <mugunthanvnm@ti.com>
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
> 
> Regards
> Mugunthan V N

This restores throughput to the level of 3.7.0

Tested-by: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
