From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net, bluetooth: don't attempt to free a channel that wasn't created
Date: Thu,  4 Oct 2012 19:59:57 -0400
Message-ID: <1349395197-12395-1-git-send-email-sasha.levin@oracle.com>
Cc: levinsasha928@gmail.com, davej@redhat.com,
	linux-kernel@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:24071 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472Ab2JEAAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 20:00:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We may currently attempt to free a channel which wasn't created due to
an error in the initialization path, this would cause a NULL ptr deref.

Introduced in commit 61d6ef3e ("Bluetooth: Make better use of l2cap_chan
reference counting").

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/bluetooth/l2cap_sock.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 083f2bf..66c295a 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1083,7 +1083,8 @@ static void l2cap_sock_destruct(struct sock *sk)
 {
 	BT_DBG("sk %p", sk);
 
-	l2cap_chan_put(l2cap_pi(sk)->chan);
+	if (l2cap_pi(sk)->chan)
+		l2cap_chan_put(l2cap_pi(sk)->chan);
 	if (l2cap_pi(sk)->rx_busy_skb) {
 		kfree_skb(l2cap_pi(sk)->rx_busy_skb);
 		l2cap_pi(sk)->rx_busy_skb = NULL;
-- 
1.7.12
