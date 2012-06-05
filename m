From: Hong zhi guo <honkiko@gmail.com>
Subject: [PATCH] macvtap: use set_curren_state to ensure mb
Date: Tue, 5 Jun 2012 18:46:36 +0800
Message-ID: <CAA7+ByX7Kp+Zh3ZQ2D6rSuhu6WCeqL-1MgDi9gy-0hHizVXncg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, arnd@arndb.de, zhiguo.hong@nsn.com,
	vikifang@juniper.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:59410 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab2FEKqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 06:46:37 -0400
Received: by wibhj8 with SMTP id hj8so3783539wib.1
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 03:46:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace raw assignment of current->state with
set_current_state(TASK_...) to ensure memory barrier.

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 drivers/net/macvtap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 2ee56de..62754f6 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -853,7 +853,7 @@ static ssize_t macvtap_do_read(struct
macvtap_queue *q, struct kiocb *iocb,

 	add_wait_queue(sk_sleep(&q->sk), &wait);
 	while (len) {
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);

 		/* Read frames from the queue */
 		skb = skb_dequeue(&q->sk.sk_receive_queue);
@@ -875,7 +875,7 @@ static ssize_t macvtap_do_read(struct
macvtap_queue *q, struct kiocb *iocb,
 		break;
 	}

-	current->state = TASK_RUNNING;
+	set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk_sleep(&q->sk), &wait);
 	return ret;
 }
-- 
1.7.4.1
