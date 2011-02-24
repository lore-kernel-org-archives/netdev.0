From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/17] tipc: Minor optimization to topology service connection establishment
Date: Wed, 23 Feb 2011 20:26:40 -0500
Message-ID: <1298510805-20630-13-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34523 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111Ab1BXB1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:14 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates a local iovec structure containing no data, which was
previously used during the establishment of a topology service connection,
since the same effect can be achieved by passing in a NULL pointer and
an iovec length of zero.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/subscr.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 1387372..aae9eae 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -472,8 +472,6 @@ static void subscr_named_msg_event(void *usr_handle,
 				   struct tipc_portid const *orig,
 				   struct tipc_name_seq const *dest)
 {
-	static struct iovec msg_sect = {NULL, 0};
-
 	struct subscriber *subscriber;
 	u32 server_port_ref;
 
@@ -523,7 +521,7 @@ static void subscr_named_msg_event(void *usr_handle,
 
 	/* Send an ACK- to complete connection handshaking */
 
-	tipc_send(server_port_ref, 1, &msg_sect);
+	tipc_send(server_port_ref, 0, NULL);
 
 	/* Handle optional subscription request */
 
-- 
1.7.3.3

