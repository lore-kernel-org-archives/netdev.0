From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 1/2] tipc: increase size of tipc discovery messages
Date: Thu, 5 Mar 2015 10:23:48 +0100
Message-ID: <1425547429-21164-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <richard.alpe@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:56926 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663AbbCEJ2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 04:28:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

The payload area following the TIPC discovery message header is an
opaque area defined by the media. INT_H_SIZE was enough for
Ethernet/IB/IPv4 but needs to be expanded to carry IPv6 addressing
information.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/discover.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index feef375..5967506 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -86,7 +86,7 @@ static void tipc_disc_init_msg(struct net *net, struct sk_buff *buf, u32 type,
 
 	msg = buf_msg(buf);
 	tipc_msg_init(tn->own_addr, msg, LINK_CONFIG, type,
-		      INT_H_SIZE, dest_domain);
+		      MAX_H_SIZE, dest_domain);
 	msg_set_non_seq(msg, 1);
 	msg_set_node_sig(msg, tn->random);
 	msg_set_dest_domain(msg, dest_domain);
@@ -249,7 +249,7 @@ void tipc_disc_rcv(struct net *net, struct sk_buff *buf,
 
 	/* Send response, if necessary */
 	if (respond && (mtyp == DSC_REQ_MSG)) {
-		rbuf = tipc_buf_acquire(INT_H_SIZE);
+		rbuf = tipc_buf_acquire(MAX_H_SIZE);
 		if (rbuf) {
 			tipc_disc_init_msg(net, rbuf, DSC_RESP_MSG, bearer);
 			tipc_bearer_send(net, bearer->identity, rbuf, &maddr);
@@ -359,8 +359,7 @@ int tipc_disc_create(struct net *net, struct tipc_bearer *b_ptr,
 	req = kmalloc(sizeof(*req), GFP_ATOMIC);
 	if (!req)
 		return -ENOMEM;
-
-	req->buf = tipc_buf_acquire(INT_H_SIZE);
+	req->buf = tipc_buf_acquire(MAX_H_SIZE);
 	if (!req->buf) {
 		kfree(req);
 		return -ENOMEM;
-- 
2.1.4
