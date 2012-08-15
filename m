From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 08/14] Bluetooth: L2CAP - Fix info leak via getsockname()
Date: Wed, 15 Aug 2012 23:31:51 +0200
Message-ID: <1345066317-22512-9-git-send-email-minipli@googlemail.com>
References: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34449 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757432Ab2HOVdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 17:33:10 -0400
In-Reply-To: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The L2CAP code fails to initialize the l2_bdaddr_type member of struct
sockaddr_l2 and the padding byte added for alignment. It that for leaks
two bytes kernel stack via the getsockname() syscall. Add an explicit
memset(0) before filling the structure to avoid the info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
---
 net/bluetooth/l2cap_sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index a4bb27e..df5ea9e 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -245,6 +245,7 @@ static int l2cap_sock_getname(struct socket *sock, struct sockaddr *addr, int *l
 
 	BT_DBG("sock %p, sk %p", sock, sk);
 
+	memset(la, 0, sizeof(struct sockaddr_l2));
 	addr->sa_family = AF_BLUETOOTH;
 	*len = sizeof(struct sockaddr_l2);
 
-- 
1.7.10.4
