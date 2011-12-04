From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bql: fix CONFIG_XPS=n build
Date: Sun, 04 Dec 2011 23:38:00 +0100
Message-ID: <1323038280.14707.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49421 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742Ab1LDWiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 17:38:06 -0500
Received: by eaak14 with SMTP id k14so3716956eaa.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 14:38:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_queue_release() should be called even if CONFIG_XPS=n
to properly release device reference.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/net-sysfs.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 3bf72b6..9d13463 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1221,9 +1221,7 @@ static void netdev_queue_release(struct kobject *kobj)
 
 static struct kobj_type netdev_queue_ktype = {
 	.sysfs_ops = &netdev_queue_sysfs_ops,
-#ifdef CONFIG_XPS
 	.release = netdev_queue_release,
-#endif
 	.default_attrs = netdev_queue_default_attrs,
 };
 
