From: Emrah Demir <ed@abdsec.com>
Subject: [PATCH] mISDN: Fixing missing validation in base_sock_bind()
Date: Fri,  8 Apr 2016 22:16:11 +0300
Message-ID: <1460142971-16459-1-git-send-email-ed@abdsec.com>
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de,
	Emrah Demir <ed@abdsec.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Emrah Demir <ed@abdsec.com>

Add validation code into mISDN/socket.c

Signed-off-by: Emrah Demir <ed@abdsec.com>
---
 drivers/isdn/mISDN/socket.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 0d29b5a..99e5f97 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -715,6 +715,9 @@ base_sock_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
 	if (!maddr || maddr->family != AF_ISDN)
 		return -EINVAL;
 
+	if (addr_len < sizeof(struct sockaddr_mISDN))
+		return -EINVAL;
+
 	lock_sock(sk);
 
 	if (_pms(sk)->dev) {
-- 
2.8.0.rc3
