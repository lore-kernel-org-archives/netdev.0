From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 07/14] Bluetooth: RFCOMM - Fix info leak via getsockname()
Date: Wed, 15 Aug 2012 23:31:50 +0200
Message-ID: <1345066317-22512-8-git-send-email-minipli@googlemail.com>
References: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RFCOMM code fails to initialize the trailing padding byte of struct
sockaddr_rc added for alignment. It that for leaks one byte kernel stack
via the getsockname() syscall. Add an explicit memset(0) before filling
the structure to avoid the info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
---
 net/bluetooth/rfcomm/sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 64f55ca..1a17850 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -528,6 +528,7 @@ static int rfcomm_sock_getname(struct socket *sock, struct sockaddr *addr, int *
 
 	BT_DBG("sock %p, sk %p", sock, sk);
 
+	memset(sa, 0, sizeof(*sa));
 	sa->rc_family  = AF_BLUETOOTH;
 	sa->rc_channel = rfcomm_pi(sk)->channel;
 	if (peer)
-- 
1.7.10.4
