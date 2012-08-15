From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 03/14] Bluetooth: HCI - Fix info leak in getsockopt(HCI_FILTER)
Date: Wed, 15 Aug 2012 23:31:46 +0200
Message-ID: <1345066317-22512-4-git-send-email-minipli@googlemail.com>
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

The HCI code fails to initialize the two padding bytes of struct
hci_ufilter before copying it to userland -- that for leaking two
bytes kernel stack. Add an explicit memset(0) before filling the
structure to avoid the info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
---
 net/bluetooth/hci_sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index a7f04de..a27bbc3 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -1009,6 +1009,7 @@ static int hci_sock_getsockopt(struct socket *sock, int level, int optname,
 		{
 			struct hci_filter *f = &hci_pi(sk)->filter;
 
+			memset(&uf, 0, sizeof(uf));
 			uf.type_mask = f->type_mask;
 			uf.opcode    = f->opcode;
 			uf.event_mask[0] = *((u32 *) f->event_mask + 0);
-- 
1.7.10.4
