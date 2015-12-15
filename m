From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sctp: use GFP_KERNEL in sctp_init()
Date: Tue, 15 Dec 2015 15:33:39 -0800
Message-ID: <1450222419.8474.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35397 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452AbbLOXdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 18:33:41 -0500
Received: by mail-pf0-f175.google.com with SMTP id v86so1659760pfa.2
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 15:33:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

modules init functions being called from process context, we better
use GFP_KERNEL allocations to increase our chances to get these
high-order pages we want for SCTP hash tables.

This mostly matters if SCTP module is loaded once memory got fragmented.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sctp/protocol.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 3d9ea9a48289..6c2c0accc6a0 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1419,7 +1419,7 @@ static __init int sctp_init(void)
 		if ((sctp_assoc_hashsize > (64 * 1024)) && order > 0)
 			continue;
 		sctp_assoc_hashtable = (struct sctp_hashbucket *)
-			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, order);
+			__get_free_pages(GFP_KERNEL | __GFP_NOWARN, order);
 	} while (!sctp_assoc_hashtable && --order > 0);
 	if (!sctp_assoc_hashtable) {
 		pr_err("Failed association hash alloc\n");
@@ -1452,7 +1452,7 @@ static __init int sctp_init(void)
 		if ((sctp_port_hashsize > (64 * 1024)) && order > 0)
 			continue;
 		sctp_port_hashtable = (struct sctp_bind_hashbucket *)
-			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, order);
+			__get_free_pages(GFP_KERNEL | __GFP_NOWARN, order);
 	} while (!sctp_port_hashtable && --order > 0);
 	if (!sctp_port_hashtable) {
 		pr_err("Failed bind hash alloc\n");
