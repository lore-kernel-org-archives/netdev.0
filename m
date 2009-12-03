From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 06/18] Bluetooth: Return ENETDOWN when interface is down
Date: Thu,  3 Dec 2009 19:45:43 +0100
Message-ID: <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37648 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756393AbZLCSp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:57 -0500
In-Reply-To: <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending commands to a down interface results in a timeout while clearly
it should just return ENETDOWN. When using the ioctls this works fine,
but not when using the HCI sockets sendmsg interface.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_sock.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 1ca5c7c..c3701f3 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -414,6 +414,11 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 		goto done;
 	}
 
+	if (!test_bit(HCI_UP, &hdev->flags)) {
+		err = -ENETDOWN;
+		goto done;
+	}
+
 	if (!(skb = bt_skb_send_alloc(sk, len, msg->msg_flags & MSG_DONTWAIT, &err)))
 		goto done;
 
-- 
1.6.5.2

