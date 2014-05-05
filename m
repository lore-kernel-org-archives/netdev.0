From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 19/24] net, diet: Make RPS configurable
Date: Mon,  5 May 2014 15:26:08 -0700
Message-ID: <1399328773-6531-20-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Multiple receive queues are not needed on small systems,
so allow disabling them.

This is already disabled with !SMP, but it also makes
sense to disable on very small SMP systems (like
dual core SOC)

Can be worth ~30k code and 6k data

   text	   data	    bss	    dec	    hex	filename
6923914	1398176	 634880	8956970	 88ac2a	vmlinux-with-rps
6893698	1392544	 634880	8921122	 882022	vmlinux-wo-rps

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/Kconfig b/net/Kconfig
index fe6e856..cc0264a 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -248,7 +248,7 @@ source "net/mpls/Kconfig"
 source "net/hsr/Kconfig"
 
 config RPS
-	boolean
+	bool "Support multiqueue input queues (RPS)"
 	depends on SMP && SYSFS
 	default y
 
-- 
1.9.0
