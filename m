From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/7] sky2: checksum offload plus vlan bug
Date: Thu, 24 May 2007 15:22:44 -0700
Message-ID: <20070524222538.462630124@linux-foundation.org>
References: <20070524222242.555399884@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:53988 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751540AbXEXWax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 18:30:53 -0400
Content-Disposition: inline; filename=sky2-vlan-ins.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver was not correctly setting up transmit descriptor when doing
VLAN tag insertion with checksum offload.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-05-22 10:42:36.000000000 -0700
+++ b/drivers/net/sky2.c	2007-05-22 10:43:12.000000000 -0700
@@ -1432,7 +1432,7 @@ static int sky2_xmit_frame(struct sk_buf
 		tcpsum = offset << 16;		/* sum start */
 		tcpsum |= offset + skb->csum_offset;	/* sum write */
 
-		ctrl = CALSUM | WR_SUM | INIT_SUM | LOCK_SUM;
+		ctrl |= CALSUM | WR_SUM | INIT_SUM | LOCK_SUM;
 		if (ip_hdr(skb)->protocol == IPPROTO_UDP)
 			ctrl |= UDPTCP;
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

