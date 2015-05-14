From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] ip_tunnel: Report Rx dropped in
 ip_tunnel_get_stats64
Date: Thu, 14 May 2015 13:04:54 -0700
Message-ID: <20150514200454.1537.43655.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965180AbbENUE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 16:04:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rx_dropped stat wasn't being reported when ip_tunnel_get_stats64 was
called.  This was leading to some confusing results in my debug as I was
seeing rx_errors increment but no other value which pointed me toward the
type of error being seen.

This change corrects that by copying the value over from
dev->stats.rx_dropped inot tot->rx_dropped.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/ip_tunnel_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 3998b1822d85..a6a980680b8a 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -191,6 +191,7 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
 	tot->rx_length_errors = dev->stats.rx_length_errors;
 	tot->rx_frame_errors = dev->stats.rx_frame_errors;
+	tot->rx_dropped = dev->stats.rx_dropped;
 	tot->rx_errors = dev->stats.rx_errors;
 
 	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
