From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: set the skb->ip_summed correctly when sending over loopback.
Date: Wed, 17 Sep 2008 16:03:01 -0400
Message-ID: <1221681781-1904-1-git-send-email-vladislav.yasevich@hp.com>
References: <20080917101130.GU6798@shell>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:11561 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879AbYIQUDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 16:03:05 -0400
In-Reply-To: <20080917101130.GU6798@shell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Loopback used to clobber the ip_summed filed which sctp then used
to figure out if it needed to do checksumming or not.  Now that
loopback doesn't do that any more, sctp needs to set the ip_summed
field correctly.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 0dc4a7d..225c712 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -533,7 +533,8 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	if (!(dst->dev->features & NETIF_F_NO_CSUM)) {
 		crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
 		crc32 = sctp_end_cksum(crc32);
-	}
+	} else
+		nskb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	/* 3) Put the resultant value into the checksum field in the
 	 *    common header, and leave the rest of the bits unchanged.
-- 
1.5.3.5

