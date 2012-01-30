From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] net/hyperv: rx_bytes should account the ether header size
Date: Mon, 30 Jan 2012 16:14:02 +0800
Message-ID: <CAPgLHd8M7vPra_gTH5J1RmR4nmSeuDEGCjghatd1BsOJEeGKKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: haiyangz@microsoft.com, kys@microsoft.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:39475 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab2A3IOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 03:14:03 -0500
Received: by qadc10 with SMTP id c10so1933840qad.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 00:14:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

skb->len after call eth_type_trans() does not include the ether
header size, but rx_bytes should account it.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/hyperv/netvsc_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1a1ca6c..9dccc7a 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -298,7 +298,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 	skb->ip_summed = CHECKSUM_NONE;
 
 	net->stats.rx_packets++;
-	net->stats.rx_bytes += skb->len;
+	net->stats.rx_bytes += packet->total_data_buflen;
 
 	/*
 	 * Pass the skb back up. Network stack will deallocate the skb when it
-- 
1.7.1
