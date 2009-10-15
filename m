From: Gabor Gombas <gombasg@sztaki.hu>
Subject: Re: [PATCH] Re: PACKET_TX_RING: packet size is too long
Date: Thu, 15 Oct 2009 22:10:29 +0200
Message-ID: <20091015201028.GA9780@boogie.lpds.sztaki.hu>
References: <20091009090711.GG23133@boogie.lpds.sztaki.hu>
 <20091009220546.GB7618@boogie.lpds.sztaki.hu>
 <20091013.005438.32630424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johann.baudy@gnu-log.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from boogie.lpds.sztaki.hu ([193.224.70.237]:45617 "EHLO
	boogie.lpds.sztaki.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbZJOULH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 16:11:07 -0400
Content-Disposition: inline
In-Reply-To: <20091013.005438.32630424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently PACKET_TX_RING forces certain amount of every frame to remain
unused. This probably originates from an early version of the
PACKET_TX_RING patch that in fact used the extra space when the (since
removed) CONFIG_PACKET_MMAP_ZERO_COPY option was enabled. The current
code does not make any use of this extra space.

This patch removes the extra space reservation and lets userspace make
use of the full frame size.

Signed-off-by: Gabor Gombas <gombasg@sztaki.hu>
---

On Tue, Oct 13, 2009 at 12:54:38AM -0700, David Miller wrote:

> Gabor, please resubmit your patch with a proper Signed-off-by:
> tag so I can apply it if it is correct.

Sure. I have pumped out more than 150 GiB of data using this patch
without apparent ill effects so it is also tested now.

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f9f7177..745a016 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -985,10 +985,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		goto out_put;
 
 	size_max = po->tx_ring.frame_size
-		- sizeof(struct skb_shared_info)
-		- po->tp_hdrlen
-		- LL_ALLOCATED_SPACE(dev)
-		- sizeof(struct sockaddr_ll);
+		- (po->tp_hdrlen - sizeof(struct sockaddr_ll));
 
 	if (size_max > dev->mtu + reserve)
 		size_max = dev->mtu + reserve;
-- 
1.6.5

-- 
     ---------------------------------------------------------
     MTA SZTAKI Computer and Automation Research Institute
                Hungarian Academy of Sciences
     ---------------------------------------------------------
