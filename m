From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 04/14] Bluetooth: HCI - Fix info leak via getsockname()
Date: Wed, 15 Aug 2012 23:31:47 +0200
Message-ID: <1345066317-22512-5-git-send-email-minipli@googlemail.com>
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

The HCI code fails to initialize the hci_channel member of struct
sockaddr_hci and that for leaks two bytes kernel stack via the
getsockname() syscall. Initialize hci_channel with 0 to avoid the
info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
---
 net/bluetooth/hci_sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index a27bbc3..19fdac7 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -694,6 +694,7 @@ static int hci_sock_getname(struct socket *sock, struct sockaddr *addr,
 	*addr_len = sizeof(*haddr);
 	haddr->hci_family = AF_BLUETOOTH;
 	haddr->hci_dev    = hdev->id;
+	haddr->hci_channel= 0;
 
 	release_sock(sk);
 	return 0;
-- 
1.7.10.4
