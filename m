From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: [PATCH net-next-2.6] Have atalk_route_packet() return
 NET_RX_SUCCESS not NET_XMIT_SUCCESS
Date: Sun, 13 Sep 2009 16:18:43 +0930
Message-ID: <20090913161843.2e2174ba@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, acme@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:34175 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbZIMGsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2009 02:48:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have atalk_route_packet() return NET_RX_SUCCESS not NET_XMIT_SUCCESS

atalk_route_packet() returns NET_RX_DROP if it's call to
aarp_send_ddp() returns NET_XMIT_DROP. If aarp_send_ddp() returns
anything else atalk_route_packet() should return NET_RX_SUCCESS, not
NET_XMIT_SUCCESS.

Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 4a6ff2b..b1a4290 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1372,7 +1372,7 @@ static int atalk_route_packet(struct sk_buff *skb, struct net_device *dev,
 
 	if (aarp_send_ddp(rt->dev, skb, &ta, NULL) == NET_XMIT_DROP)
 		return NET_RX_DROP;
-	return NET_XMIT_SUCCESS;
+	return NET_RX_SUCCESS;
 free_it:
 	kfree_skb(skb);
 drop:
