From: akpm@osdl.org
Subject: [patch 06/10] tun/tap ARP monitor support
Date: Mon, 24 Jan 2005 18:57:13 -0800
Message-ID: <200501250257.j0P2vfl20267@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        tommy.christensen@tpack.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Tommy Christensen <tommy.christensen@tpack.net>

But as stated in bonding.txt, the ARP monitor requires the underlying
driver to update dev->trans_start and dev->last_rx.

The patch below adds the required functionality to the TUN/TAP driver.
Please test if this helps in your case.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/tun.c |    2 ++
 1 files changed, 2 insertions(+)

diff -puN drivers/net/tun.c~tun-tan-arp-monitor-support drivers/net/tun.c
--- 25/drivers/net/tun.c~tun-tan-arp-monitor-support	2005-01-24 18:55:47.450083328 -0800
+++ 25-akpm/drivers/net/tun.c	2005-01-24 18:55:47.454082720 -0800
@@ -113,6 +113,7 @@ static int tun_net_xmit(struct sk_buff *
 
 	/* Queue packet */
 	skb_queue_tail(&tun->readq, skb);
+	dev->trans_start = jiffies;
 
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
@@ -259,6 +260,7 @@ static __inline__ ssize_t tun_get_user(s
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
  
 	netif_rx_ni(skb);
+	tun->dev->last_rx = jiffies;
    
 	tun->stats.rx_packets++;
 	tun->stats.rx_bytes += len;
_
