From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 4/5] qlge: Fix timeout on indexed register wait.
Date: Sun,  7 Jun 2009 16:58:28 -0700
Message-ID: <1244419109-355-5-git-send-email-ron.mercer@qlogic.com>
References: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:19996 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbZFHAGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 20:06:23 -0400
In-Reply-To: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 8 banks of 'sub-registers' each of which are accessed
through address/data register pair.  An example would be reading
flash or the xgmac.  Accessing these require the driver to wait for
a ready bit before writing the address and then accessing the data.
This patch increases the timeout to 100us to prevent timeouts
that have been seen on some platforms.
These register are accessed in process context only.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index fcb159e..e186071 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -50,7 +50,7 @@
 #define MAX_INTER_FRAME_WAIT 10	/* 10 usec max interframe-wait for coalescing */
 #define DFLT_INTER_FRAME_WAIT (MAX_INTER_FRAME_WAIT/2)
 #define UDELAY_COUNT 3
-#define UDELAY_DELAY 10
+#define UDELAY_DELAY 100
 
 
 #define TX_DESC_PER_IOCB 8
-- 
1.6.0.2

