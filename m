From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 3/6] [IPROUTE2]: Update pkt_sched.h (to resemble the kernel
	one)
Date: Wed, 12 Sep 2007 12:14:14 +0200
Message-ID: <1189592054.26927.24.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:39721 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964896AbXILKOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:14:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit ef065a43b8900fbc0763eac0fa0a9a8a00c8aaa2
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Tue Sep 11 16:17:46 2007 +0200

    [IPROUTE2]: Update pkt_sched.h (to resemble the kernel one)
    
     Extend the tc_ratespec struct, with two parameters: 1) "cell_align"
     that allow adjusting the alignment of the rate table. 2) "overhead"
     that allow adding a packet overhead before the lookup in the kernel.
    
     This is done in order to, add support to changing the rate table to
     use the upper-boundry L2T (length to time) value. Currently we use the
     lower-boundry, which result in under-estimating the actual bandwidth
     usage.
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 268c515..919af93 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -77,8 +77,8 @@ struct tc_ratespec
 {
 	unsigned char	cell_log;
 	unsigned char	__reserved;
-	unsigned short	feature;
-	short		addend;
+	unsigned short	overhead;
+	short		cell_align;
 	unsigned short	mpu;
 	__u32		rate;
 };

