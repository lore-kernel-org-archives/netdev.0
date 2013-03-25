From: tingwei liu <tingw.liu@gmail.com>
Subject: [PATCH v2 1/1]core:Change a wrong explain about dev_get_by_name
Date: Mon, 25 Mar 2013 12:10:51 +0800
Message-ID: <CA+qZnSTm8kdmrzQLc03Jyk81cBtEpCNHqsT1fFCQ_vstzYcOiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Linus Torvalds <linus971@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f173.google.com ([209.85.210.173]:61300 "EHLO
	mail-ia0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab3CYEKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 00:10:52 -0400
Received: by mail-ia0-f173.google.com with SMTP id h37so5178591iak.18
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 21:10:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tingwei Liu <tingw.liu@gmail.com>
Date: Mon, 25 Mar 2013 11:09:59 +0800
Subject: [PATCH] Change a wrong explain about dev_get_by_name

a long time ago by the  commit.

 commit 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2
 Author: Linus Torvalds <torvalds@ppc970.osdl.org>
 Date:   Sat Apr 16 15:20:36 2005 -0700

    Linux-2.6.12-rc2

    Initial git repository build. I'm not bothering with the full history,
    even though we have it. We can create a separate "historical" git
    archive of that later if we want to, and in the meantime it's about
    3.2GB when imported into git - space that would just make the early
    git days unnecessarily complicated, when we don't have a lot of good
    infrastructure for it.

    Let it rip!

When function "list_netdevice" get write lock "dev_base_lock" only
disable soft interrupt. So dev_get_by_name get read lock
"dev_base_lock", can not called on interrupt context.


Signed-off-by: Tingwei Liu <tingw.liu@gmail.com>
---
Changes from v1:
- add change log
- add the commnet

 net/core/dev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d540ced..20c5c7c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -700,10 +700,10 @@ EXPORT_SYMBOL(dev_get_by_name_rcu);
  *     @name: name to find
  *
  *     Find an interface by name. This can be called from any
- *     context and does its own locking. The returned handle has
- *     the usage count incremented and the caller must use dev_put() to
- *     release it when it is no longer needed. %NULL is returned if no
- *     matching device is found.
+ *     context except hard irq context and does its own locking.
+ *     The returned handle has the usage count incremented and the
+ *     caller must use dev_put() to release it when it is no longer
+ *     needed. %NULL is returned if no matching device is found.
  */

 struct net_device *dev_get_by_name(struct net *net, const char *name)
--
1.6.0.2
