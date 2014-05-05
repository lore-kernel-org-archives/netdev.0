From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 20/24] net, diet: Make XPS configurable
Date: Mon,  5 May 2014 15:26:09 -0700
Message-ID: <1399328773-6531-21-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Not needed on small systems. Already disabled with !SMP,
but also makes sense to explicitely disabled on very
small multi-core SOCKs.

Saves ~6k text, but increases the data segment by a
mysterious ~4k (some padding?)

   text	   data	    bss	    dec	    hex	filename
6893698	1392544	 634880	8921122	 882022	vmlinux-with-xps
6887542	1396544	 634880	8918966	 8817b6	vmlinux-wo-xps

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/Kconfig b/net/Kconfig
index cc0264a..2437348 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -259,7 +259,7 @@ config RFS_ACCEL
 	default y
 
 config XPS
-	boolean
+	bool "Support multiqueue transmit queues (XPS)"
 	depends on SMP
 	default y
 
-- 
1.9.0
