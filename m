From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: check fragmentation in LRO get_frag_header()
Date: Mon, 08 Dec 2008 10:17:36 +0100
Message-ID: <493CE630.3010809@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1924 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751479AbYLHJRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 04:17:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a fragmentation check to myri10ge's LRO get_frag_header() callback.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com> 

--- linux-git/drivers/net/myri10ge/myri10ge.c	2008-12-08 10:12:11.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-12-08 10:12:21.000000000 +0100
@@ -2229,6 +2229,8 @@ myri10ge_get_frag_header(struct skb_frag
 	*ip_hdr = iph;
 	if (iph->protocol != IPPROTO_TCP)
 		return -1;
+	if (iph->frag_off & htons(IP_MF | IP_OFFSET))
+		return -1;
 	*hdr_flags |= LRO_TCP;
 	*tcpudp_hdr = (u8 *) (*ip_hdr) + (iph->ihl << 2);
 


