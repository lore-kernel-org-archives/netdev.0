From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Tue, 31 Aug 2010 11:10:52 +0200
Message-ID: <20100831111052.31f22185@marrow.netinsight.se>
References: <20100831011348.GA11993@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:48481 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753550Ab0HaJVD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 05:21:03 -0400
In-Reply-To: <20100831011348.GA11993@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Aug 2010 21:13:49 -0400
Dave Jones <davej@redhat.com> wrote:

> I installed the Fedora 14 alpha, which is based on 2.6.35.2, and hit
> the following trace..
> 
> WARNING: at lib/dma-debug.c:811 check_unmap+0x212/0x59b()
> Hardware name:  
> via-velocity 0000:00:0e.0: DMA-API: device driver frees DMA memory with different size [device address=0x00000000194ba27e] [map size=66 bytes] [unmap size=182 bytes]

I can't reproduce it here, but does the patch below help for you?

// Simon

>From 81fe86ef9e4be4be43cc75e8320384a0708cef1a Mon Sep 17 00:00:00 2001
From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Tue, 31 Aug 2010 08:41:26 +0200
Subject: [PATCH] via-velocity: Correct packet length on tx free

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index fd69095..305192e 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1721,7 +1721,7 @@ static void velocity_free_tx_buf(struct velocity_info *vptr,
 			/* For scatter-gather */
 			if (skb_shinfo(skb)->nr_frags > 0)
 				pktlen = max_t(size_t, pktlen,
-						td->td_buf[i].size & ~TD_QUEUE);
+						skb_headlen(skb));
 
 			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i],
 					le16_to_cpu(pktlen), PCI_DMA_TODEVICE);
-- 
1.7.0.4


