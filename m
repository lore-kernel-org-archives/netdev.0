From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH RFT net-next 0/4] via-rhine receive buffers rework
Date: Tue, 7 Apr 2015 21:31:10 +0200
Message-ID: <20150407193110.GB24631@electric-eye.fr.zoreil.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
 <87wq1plyjz.fsf@spindle.srvr.nix>
 <87sicci5c1.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: Nix <nix@esperi.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53973 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbbDGTbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:31:24 -0400
Content-Disposition: inline
In-Reply-To: <87sicci5c1.fsf@spindle.srvr.nix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nix <nix@esperi.org.uk> :
[...]
> No crashes in several hours of running: looks good!

Mildly. :o/

You may never notice if you don't resume and the reset work queue doesn't
run but patch #4 lacks the bits below.

(rx_head_desc should go away)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index a54a9f4..7f31c3a 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1244,6 +1244,7 @@ static void rhine_reset_rbufs(struct rhine_private *rp)
 	int i;
 
 	rp->cur_rx = 0;
+	rp->rx_head_desc = rp->rx_ring;
 
 	for (i = 0; i < RX_RING_SIZE; i++)
 		rp->rx_ring[i].rx_status = cpu_to_le32(DescOwn);
@@ -1268,7 +1269,6 @@ static int alloc_rbufs(struct net_device *dev)
 	int rc, i;
 
 	rp->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
-	rp->rx_head_desc = &rp->rx_ring[0];
 	next = rp->rx_ring_dma;
 
 	/* Init the ring entries */
