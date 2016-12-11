From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] Signed-off-by: Jan Wang <bbw725@163.com>
Date: Sun, 11 Dec 2016 12:27:56 -0800
Message-ID: <1481488076.6603.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481470312-8497-1-git-send-email-bbw725@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jan Wang <bbw725@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34939 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752588AbcLKU16 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 15:27:58 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so8604415pga.2
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 12:27:58 -0800 (PST)
In-Reply-To: <1481470312-8497-1-git-send-email-bbw725@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-12-11 at 23:31 +0800, Jan Wang wrote:
> [net]: Missing init queue tail
> 
> Accept queue tail doesn't initialize NULL.
> Though looks like no harm, unify it with reqsk_queue_remove(
> it will initialize tail to NULL when empty).

Well, if having a NULL or not causes no harm, what about removing
code, instead of adding some defensive one ?

Also your patch submission is wrong :
Title should not include 'Signed-off-by...' 

Anyway, net-next is closed, you'll have to wait before submitting such a
change.

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 6ebe13eb1c4cbcd84c4b3345b051b3320d7591e6..a655c6aea7c0c8c429d5629c7fb639d6de832438 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -195,8 +195,6 @@ static inline struct request_sock *reqsk_queue_remove(struct request_sock_queue
 	if (req) {
 		sk_acceptq_removed(parent);
 		queue->rskq_accept_head = req->dl_next;
-		if (queue->rskq_accept_head == NULL)
-			queue->rskq_accept_tail = NULL;
 	}
 	spin_unlock_bh(&queue->rskq_lock);
 	return req;
