From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] pasemi_mac: Access iph->tot_len with correct endianness
Date: Tue, 01 Jul 2008 10:22:45 -0700
Message-ID: <ada63rpecyi.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: olof@lixom.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:62344 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbYGARWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 13:22:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iph->tot_len is stored in network byte order, so access it using
ntohs().  This doesn't have any real world impact on pasemi_mac, since
the device only exists as part of a big-endian system-on-chip, but
fixing this gets rid of a sparse warning and avoids having a bad example
in the tree.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/pasemi_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 3b2a6c5..993d87c 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -277,7 +277,7 @@ static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
 	*tcph = tcp_hdr(skb);
 
 	/* check if ip header and tcp header are complete */
-	if (iph->tot_len < ip_len + tcp_hdrlen(skb))
+	if (ntohs(iph->tot_len) < ip_len + tcp_hdrlen(skb))
 		return -1;
 
 	*hdr_flags = LRO_IPV4 | LRO_TCP;
