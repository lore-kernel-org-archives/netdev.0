From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] ehea: Access iph->tot_len with correct endianness
Date: Tue, 01 Jul 2008 10:20:33 -0700
Message-ID: <ada7ic5ed26.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, themann@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:13148 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbYGARUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 13:20:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iph->tot_len is stored in network byte order, so access it using
ntohs().  This doesn't have any real world impact on ehea, since ehea
only exists for big-endian platfroms (at the moment at least) but fixing
this gets rid of a sparse warning and avoids having a bad example in the
tree.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/ehea/ehea_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 075fd54..451b7e6 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -616,7 +616,7 @@ static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
 	*tcph = tcp_hdr(skb);
 
 	/* check if ip header and tcp header are complete */
-	if (iph->tot_len < ip_len + tcp_hdrlen(skb))
+	if (ntohs(iph->tot_len) < ip_len + tcp_hdrlen(skb))
 		return -1;
 
 	*hdr_flags = LRO_IPV4 | LRO_TCP;
