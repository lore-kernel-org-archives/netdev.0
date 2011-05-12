From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 6/9] Bluetooth: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
Date: Thu, 12 May 2011 16:50:09 -0700
Message-ID: <1305244212-19183-7-git-send-email-sboyd@codeaurora.org>
References: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
To: linux-bluetooth@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling DEBUG_STRICT_USER_COPY_CHECKS causes the following
warning:

In function 'copy_from_user',
    inlined from 'rfcomm_sock_setsockopt' at
    net/bluetooth/rfcomm/sock.c:705:
arch/x86/include/asm/uaccess_64.h:65:
warning: call to 'copy_from_user_overflow' declared with
attribute warning: copy_from_user() buffer size is not provably
correct

presumably due to buf_size being signed causing GCC to fail to
see that buf_size can't become negative.

Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 net/bluetooth/rfcomm/sock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 66cc1f0..0698b37 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -679,7 +679,8 @@ static int rfcomm_sock_setsockopt(struct socket *sock, int level, int optname, c
 {
 	struct sock *sk = sock->sk;
 	struct bt_security sec;
-	int len, err = 0;
+	int err = 0;
+	size_t len;
 	u32 opt;
 
 	BT_DBG("sk %p", sk);
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
