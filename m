From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: diag: add a scheduling point in
 inet_diag_dump_icsk()
Date: Mon, 14 Mar 2016 15:40:00 -0700
Message-ID: <1457995200.31401.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35502 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbcCNWkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 18:40:02 -0400
Received: by mail-pf0-f175.google.com with SMTP id n5so107022519pfn.2
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 15:40:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On loaded TCP servers, looking at millions of sockets can hold
cpu for many seconds, if the lookup condition is very narrow.

(eg : ss dst 1.2.3.4 )

Better add a cond_resched() to allow other processes to access
the cpu.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 6029157..7883473 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -879,6 +879,7 @@ next_normal:
 		}
 
 		spin_unlock_bh(lock);
+		cond_resched();
 	}
 
 done:
