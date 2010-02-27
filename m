From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 9/9] Bluetooth: Fix out of scope variable access in hci_sock_cmsg()
Date: Sat, 27 Feb 2010 23:38:38 +0100
Message-ID: <d4c55eff69c7c6c428d9416fa75de71e5f231dd2.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
 <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
 <8978111e2d148f75bd5e329a14600feadc567381.1267276098.git.marcel@holtmann.org>
 <10f7891f998e84acfa31ac9c5a0fea052c39ecb8.1267276098.git.marcel@holtmann.org>
 <c13854cef4751000b968d4e8ac95796562d5b96f.1267276098.git.marcel@holtmann.org>
 <ca325f698996c1a0770a67f41e7dc97a007d8bc2.1267276098.git.marcel@holtmann.org>
 <b914a250e7b390c713b36a9405a39c4c11abad80.1267276098.git.marcel@holtmann.org>
 <943da25d95c7e8fd8c39dbf09e030f5da46f5d85.1267276098.git.marcel@holtmann.org>
 <705e5711b61e9622b2d88850f38c219014aa0780.1267276098.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54704 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936369Ab0B0Wk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:26 -0500
In-Reply-To: <705e5711b61e9622b2d88850f38c219014aa0780.1267276098.git.marcel@holtmann.org>
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Felix Soden <johfel@users.sourceforge.net>

The pointer data can point to the variable ctv.
Access to data happens when ctv is already out of scope.

Signed-off-by: Johann Felix Soden <johfel@users.sourceforge.net>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 688cfeb..b0e6108 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -338,8 +338,8 @@ static inline void hci_sock_cmsg(struct sock *sk, struct msghdr *msg, struct sk_
 		data = &tv;
 		len = sizeof(tv);
 #ifdef CONFIG_COMPAT
+		struct compat_timeval ctv;
 		if (msg->msg_flags & MSG_CMSG_COMPAT) {
-			struct compat_timeval ctv;
 			ctv.tv_sec = tv.tv_sec;
 			ctv.tv_usec = tv.tv_usec;
 			data = &ctv;
-- 
1.6.6

