From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: restore fastopen operations
Date: Wed, 30 Sep 2015 06:18:23 -0700
Message-ID: <1443619103.32531.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36531 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755408AbbI3NSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 09:18:25 -0400
Received: by pablk4 with SMTP id lk4so40340756pab.3
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 06:18:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I accidentally cleared fastopenq.max_qlen in reqsk_queue_alloc()
while max_qlen can be set before listen() is called,
using TCP_FASTOPEN socket option for example.

Fixes: 0536fcc039a8 ("tcp: prepare fastopen code for upcoming listener changes")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/request_sock.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index e22cfa4ed25f817dbc4871e1618349b2..ef031d959d80f2b45e4077680026a0f8 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -64,7 +64,6 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 	queue->fastopenq.rskq_rst_head = NULL;
 	queue->fastopenq.rskq_rst_tail = NULL;
 	queue->fastopenq.qlen = 0;
-	queue->fastopenq.max_qlen = 0;
 
 	queue->rskq_accept_head = NULL;
 	lopt->nr_table_entries = nr_table_entries;
