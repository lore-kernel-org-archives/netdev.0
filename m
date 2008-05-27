From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/7] [DCCP]: Fix to handle short sequence numbers packet correctly
Date: Tue, 27 May 2008 09:32:41 +0100
Message-ID: <1211877167-10995-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_bug_fixes_and_format_updates>
 <1211877167-10995-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:58085 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756644AbYE0IdS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 04:33:18 -0400
In-Reply-To: <1211877167-10995-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

RFC4340 said:
  8.5.  Pseudocode
       ...
       If P.type is not Data, Ack, or DataAck and P.X == 0 (the packet
             has short sequence numbers), drop packet and return

But DCCP has some mistake to handle short sequence numbers packet, now
it drop packet only if P.type is Data, Ack, or DataAck and P.X == 0.

This patch fixed this problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ipv4.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -739,8 +739,8 @@ int dccp_invalid_packet(struct sk_buff *skb)
 	 * If P.type is not Data, Ack, or DataAck and P.X == 0 (the packet
 	 * has short sequence numbers), drop packet and return
 	 */
-	if (dh->dccph_type >= DCCP_PKT_DATA    &&
-	    dh->dccph_type <= DCCP_PKT_DATAACK && dh->dccph_x == 0)  {
+	if ((dh->dccph_type < DCCP_PKT_DATA    ||
+	    dh->dccph_type > DCCP_PKT_DATAACK) && dh->dccph_x == 0)  {
 		DCCP_WARN("P.type (%s) not Data || [Data]Ack, while P.X == 0\n",
 			  dccp_packet_name(dh->dccph_type));
 		return 1;
-- 
1.5.5

