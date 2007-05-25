From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC]: Fix IPv6 AH calculation in outbound
Date: Fri, 25 May 2007 16:09:14 +0900
Message-ID: <20070525160914.49b54c9d.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:58793 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750776AbXEYHJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 May 2007 03:09:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

I send a patch to fix IPv6 AH calculation of outbound.
This is for the linux-2.6.22-rc2.

BTW, I sent a patch to fix kernel panic when using
inter address family IPsec on loopback.
Could you let me know the status?

Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index b696c84..128f94c 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -247,7 +247,7 @@ static int ah6_output(struct xfrm_state 
 	memcpy(tmp_base, top_iph, sizeof(tmp_base));
 
 	tmp_ext = NULL;
-	extlen = skb_transport_offset(skb) + sizeof(struct ipv6hdr);
+	extlen = skb_transport_offset(skb) - sizeof(struct ipv6hdr);
 	if (extlen) {
 		extlen += sizeof(*tmp_ext);
 		tmp_ext = kmalloc(extlen, GFP_ATOMIC);
