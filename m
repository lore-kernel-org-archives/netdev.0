From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/5] qlge: bugfix: Fix endian issue regarding shadow registers.
Date: Wed, 24 Dec 2008 10:21:34 -0800
Message-ID: <1230142896-15533-3-git-send-email-ron.mercer@qlogic.com>
References: <20081224181834.GA15470@susedev.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:27618 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbYLXSVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 13:21:36 -0500
In-Reply-To: <20081224181834.GA15470@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shadow registers are host memory locations that the chip echos queue indexes to.
The chip does this in little endian values, so they need to be swapped before referencing.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)
 mode change 100644 => 100755 drivers/net/qlge/qlge.h

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
old mode 100644
new mode 100755
index ba2e1c5..f1751a2
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1477,9 +1477,9 @@ static inline void ql_write_db_reg(u32 val, void __iomem *addr)
  * update the relevant index register and then copy the value to the
  * shadow register in host memory.
  */
-static inline unsigned int ql_read_sh_reg(const volatile void  *addr)
+static inline u32 ql_read_sh_reg(const volatile void  *addr)
 {
-	return *(volatile unsigned int __force *)addr;
+	return le32_to_cpu(*(volatile unsigned int __force *)addr);
 }
 
 extern char qlge_driver_name[];
-- 
1.6.0

