From: David Miller <davem@davemloft.net>
Subject: Re: net-next Compile error
Date: Sun, 29 Oct 2017 11:14:38 +0900 (KST)
Message-ID: <20171029.111438.246004254592681479.davem@davemloft.net>
References: <0adb27bc-e537-337e-c838-501cc14e964a@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: privat@egil-hjelmeland.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751216AbdJ2COm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 22:14:42 -0400
In-Reply-To: <0adb27bc-e537-337e-c838-501cc14e964a@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Date: Fri, 27 Oct 2017 15:50:25 +0200

> Starting with net-next commit 60e2a7780793bae0debc275a9ccd57f7da0cf195
> "tcp: TCP experimental option for SMC", I can not cross compile the
> kernel.

Thanks for the report, I've committed the following fix for this:

====================
[PATCH] tcp: Remove "linux/unaligned/access_ok.h" include.

This causes build failures:

In file included from net/ipv4/tcp_input.c:79:0:
./include/linux/unaligned/access_ok.h:7:28: error: redefinition of
'get_unaligned_le16'
In file included from ./include/asm-generic/unaligned.h:17:0,
                 from ./arch/arm/include/generated/asm/unaligned.h:1,
                 from net/ipv4/tcp_input.c:76:
./include/linux/unaligned/le_struct.h:6:19: note: previous definition
of 'get_unaligned_le16' was here
In file included from net/ipv4/tcp_input.c:79:0:
./include/linux/unaligned/access_ok.h:12:28: error: redefinition of
'get_unaligned_le32'

Plain "asm/access_ok.h", which is already included, is
sufficient.

Fixes: 60e2a7780793 ("tcp: TCP experimental option for SMC")
Reported-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_input.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 21c358c0cf2e..b62a7d1707ae 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -76,7 +76,6 @@
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
 #include <trace/events/tcp.h>
-#include <linux/unaligned/access_ok.h>
 #include <linux/static_key.h>
 
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
-- 
2.13.6
