From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH 4/4] l2cap: don't mangle cmd.len
Date: Fri, 27 Jul 2007 13:57:36 +0100
Message-ID: <E1IEPNw-0005TA-89@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	marcel@holtmann.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45200 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934204AbXG0M5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 08:57:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Since nobody uses it after we convert it to host-endian,
no need to do that at all.  At that point l2cap is endian-clean.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/bluetooth/l2cap.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 03309d2..c4e4ce4 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1754,7 +1754,6 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn, struct sk_buff *sk
 		len  -= L2CAP_CMD_HDR_SIZE;
 
 		cmd_len = le16_to_cpu(cmd.len);
-		cmd.len = cmd_len;
 
 		BT_DBG("code 0x%2.2x len %d id 0x%2.2x", cmd.code, cmd_len, cmd.ident);
 
-- 
1.5.3.GIT

