From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH] 2.6.27-rc9 QGLE make unsupported page size explicit compile failure
Date: Mon, 13 Oct 2008 18:54:55 -0700
Message-ID: <20081014015455.GA25385@susedev.qlogic.org>
References: <20081013060615.GB29358@colo.lackof.org> <20081012.230939.240550430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26126 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563AbYJNBzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 21:55:02 -0400
Content-Disposition: inline
In-Reply-To: <20081012.230939.240550430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave/Grant,
I sent this earlier today but didn't see it on the netdev list.
Thanks, Ron

This ASIC does support all page sizes. For 4k and 8k page size the TX control block needs an external scatter gather list.  For page sizes larger than 8k the max frags is satisfied by the original TX control block.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index c37ea43..38116f9 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -58,7 +58,7 @@
  */
 #if (PAGE_SHIFT == 12) || (PAGE_SHIFT == 13)	/* 4k & 8k pages */
 #define TX_DESC_PER_OAL ((MAX_SKB_FRAGS - TX_DESC_PER_IOCB) + 2)
-#elif (PAGE_SHIFT == 16)	/* 64k pages */
+#else /* all other page sizes */
 #define TX_DESC_PER_OAL 0
 #endif
 
-- 
1.6.0

