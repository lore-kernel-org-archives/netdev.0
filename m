From: Ani Sinha <ani@arista.com>
Subject: [PATCH 1/1] fix return code from fib_rules_lookup()
Date: Fri, 21 Nov 2014 22:25:21 -0800
Message-ID: <1416637521-20173-1-git-send-email-ani@arista.com>
Cc: netdev@vger.kernel.org, fruggeri@arista.com, ani@arista.com
To: davem@davemloft.net, maze@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:58081 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaKVGZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 01:25:26 -0500
Received: by mail-pd0-f169.google.com with SMTP id fp1so6593467pdb.28
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 22:25:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 fib_lookup() api returns two different types of error
 codes. When no custom FIB rules are installed and
 lookup fails, it returns ENETUNREACH. However, when
 custom rules are installed, __fib_lookup() calls
 fib_rules_lookup() which returns ESRCH when the rule
 lookup fails. This patch makes both code paths return
 identical error codes under lookup failure.


Signed-off-by: Ani Sinha <ani@arista.com>
---
 net/core/fib_rules.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 185c341..ab8e732 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -242,7 +242,7 @@ jumped:
 		}
 	}
 
-	err = -ESRCH;
+	err = -ENETUNREACH;
 out:
 	rcu_read_unlock();
 
-- 
1.7.4.4
