From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2] rose: use %*ph specifier
Date: Fri,  5 Sep 2014 18:32:18 +0300
Message-ID: <1409931138-25447-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S . Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42592 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652AbaIEPc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 11:32:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of dereference each byte let's use %*ph specifier in the printk()
calls.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
- Since v1:
- compile tested
- fix a wrong argument list
 net/rose/rose_link.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
index bc55142..e873d7d 100644
--- a/net/rose/rose_link.c
+++ b/net/rose/rose_link.c
@@ -160,7 +160,8 @@ void rose_link_rx_restart(struct sk_buff *skb, struct rose_neigh *neigh, unsigne
 		break;
 
 	case ROSE_DIAGNOSTIC:
-		printk(KERN_WARNING "ROSE: received diagnostic #%d - %02X %02X %02X\n", skb->data[3], skb->data[4], skb->data[5], skb->data[6]);
+		pr_warn("ROSE: received diagnostic #%d - %3ph\n", skb->data[3],
+			skb->data + 4);
 		break;
 
 	default:
-- 
2.1.0
