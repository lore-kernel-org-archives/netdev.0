From: David Miller <davem@davemloft.net>
Subject: [IPV4]: Add missing skb->truesize increment in ip_append_page().
Date: Tue, 22 Jan 2008 06:36:17 -0800 (PST)
Message-ID: <20080122.063617.38960312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750985AbYAVOgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:36:09 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 38D5FC8C21E
	for <netdev@vger.kernel.org>; Tue, 22 Jan 2008 06:36:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just checked the following into net-2.6

[IPV4]: Add missing skb->truesize increment in ip_append_page().
    
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index fd99fbd..e582dba 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1172,6 +1172,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 
 		skb->len += len;
 		skb->data_len += len;
+		skb->truesize += len;
 		offset += len;
 		size -= len;
 	}
