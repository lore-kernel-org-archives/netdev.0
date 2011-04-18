From: David Miller <davem@davemloft.net>
Subject: [PATCH 29/42] isdn: mISDN: socket: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:59 -0700 (PDT)
Message-ID: <20110417.173359.68128347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754046Ab1DRAee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:34 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 95BE224C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'len' is set but unused in data_sock_getsockopt().

The code should use 'len' to validate that the user's socket option is
indeed the right size.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/mISDN/socket.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 7446d8b..8e32522 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -457,6 +457,9 @@ static int data_sock_getsockopt(struct socket *sock, int level, int optname,
 	if (get_user(len, optlen))
 		return -EFAULT;
 
+	if (len != sizeof(char))
+		return -EINVAL;
+
 	switch (optname) {
 	case MISDN_TIME_STAMP:
 		if (_pms(sk)->cmask & MISDN_TIME_STAMP)
-- 
1.7.4.3

