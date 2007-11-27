From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH]: fix lro_gen_skb() alignment
Date: Tue, 27 Nov 2007 09:47:23 -0500
Message-ID: <474C2DFB.1090706@myri.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050402040004040003060500"
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2015 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753598AbXK0Orj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 09:47:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050402040004040003060500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The inet_lro.c:lro_gen_skb() function fails to include
NET_IP_ALIGN padding at the front of the sk_buffs it creates,
leading to alignment warnings on architectures which require
strict alignment (seen on sparc64).  The attached patch
adds NET_IP_ALIGN padding.

Signed off by: Andrew Gallatin <gallatin@myri.com>

Drew


--------------050402040004040003060500
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="lro_align.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lro_align.diff"

diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index ac3b1d3..91e9371 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -401,10 +401,11 @@ static struct sk_buff *lro_gen_skb(struc
 	int data_len = len;
 	int hdr_len = min(len, hlen);
 
-	skb = netdev_alloc_skb(lro_mgr->dev, hlen);
+	skb = netdev_alloc_skb(lro_mgr->dev, hlen + NET_IP_ALIGN);
 	if (!skb)
 		return NULL;
 
+	skb_reserve(skb, NET_IP_ALIGN);
 	skb->len = len;
 	skb->data_len = len - hdr_len;
 	skb->truesize += true_size;

--------------050402040004040003060500--
