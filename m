From: Gabor Gombas <gombasg@sztaki.hu>
Subject: [PATCH] Re: PACKET_TX_RING: packet size is too long
Date: Sat, 10 Oct 2009 00:05:46 +0200
Message-ID: <20091009220546.GB7618@boogie.lpds.sztaki.hu>
References: <20091009090711.GG23133@boogie.lpds.sztaki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johann.baudy@gnu-log.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from boogie.lpds.sztaki.hu ([193.224.70.237]:55305 "EHLO
	boogie.lpds.sztaki.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934687AbZJIWGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 18:06:24 -0400
Content-Disposition: inline
In-Reply-To: <20091009090711.GG23133@boogie.lpds.sztaki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Digging list archives I suspect the current value of size_max is the
remnant of the zero-copy mode that was not merged. So I propose the
following patch that IMHO makes the value of size_max consistent with
how the frame is actually handled in tpacket_fill_skb().

If the zero-copy mode is ever to be resurrected, then the user should
explicitely request it, and either the length of the extra padding
should be the same for 32-bit and 64-bit kernels or there must be a way
to query the value at run time.

Gabor

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
     ---------------------------------------------------------
     MTA SZTAKI Computer and Automation Research Institute
                Hungarian Academy of Sciences
     ---------------------------------------------------------
