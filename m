From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [RFC PATCH net-next 3/3] macvtap: Record the rx queue based on the user tap queue
Date: Sun,  7 Feb 2016 22:14:56 -0500
Message-ID: <1454901296-9915-4-git-send-email-vyasevic@redhat.com>
References: <1454901296-9915-1-git-send-email-vyasevic@redhat.com>
Cc: jasowang@redhat.com, mst@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:36621 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991AbcBHDPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 22:15:08 -0500
Received: by mail-qg0-f68.google.com with SMTP id 14so2220075qgg.3
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 19:15:07 -0800 (PST)
In-Reply-To: <1454901296-9915-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that macvlan has a basic queue selection and macvtap has
multiple qdiscs, we can record the the queue index into the skb
based on the index of the macvtap user queue.  This index will
then be used to select the right qdisc.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 810e7d3..650a374 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -821,6 +821,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 			goto err_kfree;
 	}
 
+	skb_record_rx_queue(skb, q->queue_index);
 	skb_probe_transport_header(skb, ETH_HLEN);
 
 	/* Move network header to the right position for VLAN tagged packets */
-- 
2.1.0
