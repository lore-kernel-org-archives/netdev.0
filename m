From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
Subject: [PATCH] virtio_net: fix the potential NULL pointer in xmit_skb()
Date: Fri, 14 Feb 2014 12:00:08 +0800
Message-ID: <1392350408-3811-1-git-send-email-wuzhy@linux.vnet.ibm.com>
Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:51742 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbaBNEAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 23:00:34 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wuzhy@linux.vnet.ibm.com>;
	Thu, 13 Feb 2014 21:00:34 -0700
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 8F9C26E803A
	for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 23:00:26 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1E40V4966519220
	for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 04:00:31 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1E40UKm026658
	for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 23:00:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pointer hdr isn't assigned before hdr->mhdr and hdr->hdr
are used, so it could be one invalid pointer.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/virtio_net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d75f8ed..bf6397f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -807,9 +807,9 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 
 	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
 	if (vi->mergeable_rx_bufs)
-		hdr_len = sizeof hdr->mhdr;
+		hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	else
-		hdr_len = sizeof hdr->hdr;
+		hdr_len = sizeof(struct virtio_net_hdr);
 
 	can_push = vi->any_header_sg &&
 		!((unsigned long)skb->data & (__alignof__(*hdr) - 1)) &&
-- 
1.8.4.2
