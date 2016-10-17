From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] fjes: fix format string for trace output
Date: Mon, 17 Oct 2016 16:30:57 +0200
Message-ID: <20161017143314.515133-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>,
        Taku Izumi <izumi.taku@jp.fujitsu.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:59489 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933168AbcJQOdi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:33:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phys_addr_t may be wider than a pointer and has to be printed
using the special %pap format string, as pointed out by
this new warning.

arch/x86/include/../../../drivers/net/fjes/fjes_trace.h: In function ‘trace_raw_output_fjes_hw_start_debug_req’:
arch/x86/include/../../../drivers/net/fjes/fjes_trace.h:212:563: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]

Note that this has to pass the address by reference instead of
casting it to a different type.

Fixes: b6ba737d0b29 ("fjes: ethtool -w and -W support for fjes driver")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/fjes/fjes_trace.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fjes/fjes_trace.h b/drivers/net/fjes/fjes_trace.h
index 22e8f1a4f9ee..cca01a1b3d64 100644
--- a/drivers/net/fjes/fjes_trace.h
+++ b/drivers/net/fjes/fjes_trace.h
@@ -222,8 +222,8 @@ TRACE_EVENT(fjes_hw_start_debug_req,
 		__entry->mode = req_buf->start_trace.mode;
 		__entry->buffer = req_buf->start_trace.buffer[0];
 	),
-	TP_printk("req_buf=[length=%d, mode=%d, buffer=%p]",
-		  __entry->length, __entry->mode, (void *)__entry->buffer)
+	TP_printk("req_buf=[length=%d, mode=%d, buffer=%pap]",
+		  __entry->length, __entry->mode, &__entry->buffer)
 );
 
 TRACE_EVENT(fjes_hw_start_debug,
-- 
2.9.0
