From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG in netxen_release_tx_buffers when TSO enabled on kernels
 >= 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 05:56:06 -0800
Message-ID: <1358862966.3464.3797.camel@edumazet-glaptop>
References: <1659861.dHpGAGoXHj@cpaasch-mac>
	 <1358861524.3464.3768.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36408 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab3AVN4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 08:56:09 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so4067463pad.40
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 05:56:09 -0800 (PST)
In-Reply-To: <1358861524.3464.3768.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 05:32 -0800, Eric Dumazet wrote:

> 
> Something doesn't properly test MAX_SKB_FRAGS, we should track it and
> fix.

I guess netxen driver has a bug.

Please try the following patch :

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index bc165f4..695667d 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -144,7 +144,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 					 buffrag->length, PCI_DMA_TODEVICE);
 			buffrag->dma = 0ULL;
 		}
-		for (j = 0; j < cmd_buf->frag_count; j++) {
+		for (j = 1; j < cmd_buf->frag_count; j++) {
 			buffrag++;
 			if (buffrag->dma) {
 				pci_unmap_page(adapter->pdev, buffrag->dma,
