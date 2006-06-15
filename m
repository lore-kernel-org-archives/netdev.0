From: Wei Dong <weid@nanjing-fnst.com>
Subject: [patch] e100 statistic value "rx_bytes" error
Date: Thu, 15 Jun 2006 12:17:06 +0800
Message-ID: <1150345027.3008.10.camel@L-tech>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:38533 "EHLO localmail")
	by vger.kernel.org with ESMTP id S932429AbWFOEAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 00:00:09 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All:
   When I test linux kernel(2.6.9-16), I found that maybe there is a bug
in e100 driver. See function e100_rx_indicate() at line 1847:
	nic->net_stats.rx_bytes += actual_size;
Here, actual_size is the actual size of an ethernent frame sans FCS.And
the e100 driver gets it from skb. Because "rx_bytes" is a statistc value
for a NIC, I think rx_bytes should include the FCS(4 bytes).
The following is the patch for the function in e100.c

diff -ruN old/drivers/net/e100.c new/drivers/net/e100.c
--- old/drivers/net/e100.c	2006-03-20 13:53:29.000000000 +0800
+++ new/drivers/net/e100.c	2006-06-15 11:16:04.000000000 +0800
@@ -1844,7 +1844,8 @@
 		dev_kfree_skb_any(skb);
 	} else {
 		nic->net_stats.rx_packets++;
-		nic->net_stats.rx_bytes += actual_size;
+		/* Don't forget FCS */
+		nic->net_stats.rx_bytes += actual_size + 4;
 		nic->netdev->last_rx = jiffies;
 		netif_receive_skb(skb);
 		if(work_done)

BR.
  Weidong

Signed-off-by: Weidong <weid@nanjing-fnst.com>

