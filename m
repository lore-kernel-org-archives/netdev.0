From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 32/62: xtables: consistent struct compat_xt_counters definition
Date: Tue, 16 Feb 2010 15:56:03 +0100 (MET)
Message-ID: <20100216145601.2796.39434.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52017 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538Ab0BPO4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:05 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 0a02604628c49037e1de2091d75462fd856b26ed
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Wed Feb 10 15:00:32 2010 +0100

    netfilter: xtables: consistent struct compat_xt_counters definition
    
    There is compat_u64 type which deals with different u64 type alignment
    on different compat-capable platforms, so use it and removed some
    hardcoded assumptions.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 365fabe..8b6c0e7 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -562,11 +562,7 @@ struct compat_xt_entry_target {
  * current task alignment */
 
 struct compat_xt_counters {
-#if defined(CONFIG_X86_64) || defined(CONFIG_IA64)
-	u_int32_t cnt[4];
-#else
-	u_int64_t cnt[2];
-#endif
+	compat_u64 pcnt, bcnt;			/* Packet and byte counters */
 };
 
 struct compat_xt_counters_info {
