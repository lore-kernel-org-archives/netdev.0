From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: missing lock initialization
Date: Fri, 18 Jul 2008 16:38:36 -0700
Message-ID: <20080718163836.60f5a021@extreme>
References: <20080718161048.678a9629@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50764 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756122AbYGRXih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 19:38:37 -0400
In-Reply-To: <20080718161048.678a9629@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like the xmit_lock is not being initialized in net-next

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2008-07-18 16:31:16.000000000 -0700
+++ b/net/core/dev.c	2008-07-18 16:35:31.000000000 -0700
@@ -4175,6 +4175,7 @@ static void netdev_init_one_queue(struct
 				  struct netdev_queue *queue,
 				  void *_unused)
 {
+	spin_lock_init(&queue->_xmit_lock);
 	queue->dev = dev;
 }
 
