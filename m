From: Hong zhi guo <honkiko@gmail.com>
Subject: Re: [PATCH] macvtap: use set_curren_state to ensure mb
Date: Tue, 5 Jun 2012 18:57:01 +0800
Message-ID: <CAA7+ByXUGp_agxqRXjR9EyW=Oukp2eW_-vGZkQar+3fnyTJHrg@mail.gmail.com>
References: <CAA7+ByX7Kp+Zh3ZQ2D6rSuhu6WCeqL-1MgDi9gy-0hHizVXncg@mail.gmail.com>
	<CAA7+ByVzL2kA=uN_yUVFpSnDbLgwecAi9f__QPzDoXHpt_vyaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, arnd@arndb.de, zhiguo.hong@nsn.com,
	vikifang@juniper.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41011 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084Ab2FEK5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 06:57:03 -0400
Received: by weyu7 with SMTP id u7so3480628wey.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 03:57:02 -0700 (PDT)
In-Reply-To: <CAA7+ByVzL2kA=uN_yUVFpSnDbLgwecAi9f__QPzDoXHpt_vyaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 5, 2012 at 6:46 PM, Hong zhi guo <honkiko@gmail.com> wrote:
> replace raw assignment of current->state with
> set_current_state(TASK_...) to ensure memory barrier.
>
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

Sorry for the wrong format in former mail. Corrected.

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
