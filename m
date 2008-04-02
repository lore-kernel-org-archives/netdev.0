From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] sc92031: use netdev_alloc_skb
Date: Wed, 2 Apr 2008 10:13:12 -0700
Message-ID: <20080402101312.0db8f52e@extreme>
References: <bug-10380-10286@http.bugzilla.kernel.org/>
	<20080402091435.39f99428.akpm@linux-foundation.org>
	<20080402094923.185f15dc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@sharkbay.at
To: Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Cesar Eduardo Barros <cesarb@cesarb.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59997 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756219AbYDBRN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 13:13:26 -0400
In-Reply-To: <20080402094923.185f15dc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb since it handles any NUMA node memory localtion issues
and sets skb->dev. Since device driver was not setting skb->dev, I bet
filter rules based on device would not work.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sc92031.c	2008-04-02 10:03:00.000000000 -0700
+++ b/drivers/net/sc92031.c	2008-04-02 10:03:04.000000000 -0700
@@ -796,7 +796,7 @@ static void _sc92031_rx_tasklet(struct n
 
 		rx_len -= rx_size_align + 4;
 
-		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(dev, pkt_size + NET_IP_ALIGN);
 		if (unlikely(!skb)) {
 			if (printk_ratelimit())
 				printk(KERN_ERR "%s: Couldn't allocate a skb_buff for a packet of size %u\n",
