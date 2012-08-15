From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 05/14] Bluetooth: RFCOMM - Fix info leak in getsockopt(BT_SECURITY)
Date: Wed, 15 Aug 2012 23:31:48 +0200
Message-ID: <1345066317-22512-6-git-send-email-minipli@googlemail.com>
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

The RFCOMM code fails to initialize the key_size member of struct
bt_security before copying it to userland -- that for leaking one
byte kernel stack. Initialize key_size with 0 to avoid the info
leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
---
 net/bluetooth/rfcomm/sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 7e1e596..64f55ca 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -822,6 +822,7 @@ static int rfcomm_sock_getsockopt(struct socket *sock, int level, int optname, c
 		}
 
 		sec.level = rfcomm_pi(sk)->sec_level;
+		sec.key_size = 0;
 
 		len = min_t(unsigned int, len, sizeof(sec));
 		if (copy_to_user(optval, (char *) &sec, len))
-- 
1.7.10.4
