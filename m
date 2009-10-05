From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 4/9] vxge: Fixed crash in PAE system due to
 wrong typecasting.
Date: Mon, 5 Oct 2009 05:09:38 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10910050508570.2346-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39379 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932397AbZJEJ0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:26:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fix a crash in PAE system due to wrong typecasting.

- On PAE system size_t is unsigned int which is 32bit. Avoid casting
  64 bit address to 32 bit

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN patch3/drivers/net/vxge/vxge-traffic.c patch4/drivers/net/vxge/vxge-traffic.c
--- patch3/drivers/net/vxge/vxge-traffic.c	2009-09-04 01:19:23.000000000 -0700
+++ patch4/drivers/net/vxge/vxge-traffic.c	2009-09-04 01:22:35.000000000 -0700
@@ -1232,7 +1232,7 @@ void vxge_hw_fifo_txdl_post(struct __vxg
 	vxge_hw_channel_dtr_post(&fifo->channel, txdlh);
 
 	__vxge_hw_non_offload_db_post(fifo,
-		(u64)(size_t)txdl_priv->dma_addr,
+		(u64)txdl_priv->dma_addr,
 		txdl_priv->frags - 1,
 		fifo->no_snoop_bits);
 

