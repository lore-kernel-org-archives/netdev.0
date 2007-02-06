From: akpm@linux-foundation.org
Subject: [patch 03/11] fix for crash in adummy_init()
Date: Mon, 05 Feb 2007 16:30:56 -0800
Message-ID: <200702060031.l160Vxqf004624@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dwalker@mvista.com, chas@cmf.nrl.navy.mil, mingo@elte.hu
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41522 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965239AbXBFAdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:33:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Walker <dwalker@mvista.com>

This was reported by Ingo Molnar here,

http://lkml.org/lkml/2006/12/18/119

The problem is that adummy_init() depends on atm_init() , but adummy_init()
is called first.

So I put atm_init() into subsys_initcall which seems appropriate, and it
will still get module_init() if it becomes a module.

Interesting to note that you could crash your system here if you just load
the modules in the wrong order.

Signed-off-by: Daniel Walker <dwalker@mvista.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: chas williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/atm/common.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN net/atm/common.c~fix-for-crash-in-adummy_init net/atm/common.c
--- a/net/atm/common.c~fix-for-crash-in-adummy_init
+++ a/net/atm/common.c
@@ -816,7 +816,8 @@ static void __exit atm_exit(void)
 	proto_unregister(&vcc_proto);
 }
 
-module_init(atm_init);
+subsys_initcall(atm_init);
+
 module_exit(atm_exit);
 
 MODULE_LICENSE("GPL");
_
