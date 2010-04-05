From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Add a missing local_irq_enable()
Date: Tue, 06 Apr 2010 00:41:47 +0200
Message-ID: <1270507307.9013.43.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
	 <z2m412e6f7f1004051523p6198556ak3e2ab9a52a3167d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:44667 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab0DEWly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 18:41:54 -0400
Received: by bwz1 with SMTP id 1so3154425bwz.21
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 15:41:51 -0700 (PDT)
In-Reply-To: <z2m412e6f7f1004051523p6198556ak3e2ab9a52a3167d4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 avril 2010 =C3=A0 06:23 +0800, Changli Gao a =C3=A9crit :

> It seems that irq isn't enabled when breaking the loop. Please add
>    local_irq_enable();
> after rps_unlock(queue);

Gah.. you are right, following patch needed, since David already applie=
d
Tom's patch.

[PATCH net-next-2.6] net: Add a missing local_irq_enable()

As noticed by Changli Gao, we must call local_irq_enable() after
rps_unlock()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 74f77ca..b98ddc6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3121,6 +3121,7 @@ static int process_backlog(struct napi_struct *na=
pi, int quota)
 		if (!skb) {
 			__napi_complete(napi);
 			rps_unlock(queue);
+			local_irq_enable();
 			break;
 		}
 		rps_unlock(queue);


