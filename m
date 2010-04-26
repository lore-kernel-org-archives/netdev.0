From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] r8169: more broken register writes workaround
Date: Mon, 26 Apr 2010 23:42:58 +0200
Message-ID: <20100426214258.GB7624@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 97.17.115-78.rev.gaoland.net ([78.115.17.97]:54230 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754805Ab0DZVwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 17:52:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

78f1cd02457252e1ffbc6caa44a17424a45286b8 ("fix broken register writes")
does not work for Al Viro's r8169 (XID 18000000).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2b54389..4748c21 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2826,8 +2826,13 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 	spin_lock_irq(&tp->lock);
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
 	RTL_W32(MAC4, high);
+	RTL_R32(MAC4);
+
 	RTL_W32(MAC0, low);
+	RTL_R32(MAC0);
+
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	spin_unlock_irq(&tp->lock);
-- 
1.6.6.1

