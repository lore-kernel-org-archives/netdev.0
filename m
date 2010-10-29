From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] staging: get rid of dev_base_lock
Date: Fri, 29 Oct 2010 15:19:27 +0200
Message-ID: <1288358367.2560.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38880 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756182Ab0J2NTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 09:19:32 -0400
Received: by wyf28 with SMTP id 28so3130677wyf.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 06:19:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_base_lock was the legacy rwlock used to protect netdevice list, and
is expected to vanish.

We now use RTNL and RCU locking.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/staging/wlags49_h2/wl_sysfs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/wlags49_h2/wl_sysfs.c b/drivers/staging/wlags49_h2/wl_sysfs.c
index e4c8804..9b833b3 100644
--- a/drivers/staging/wlags49_h2/wl_sysfs.c
+++ b/drivers/staging/wlags49_h2/wl_sysfs.c
@@ -42,7 +42,7 @@ static ssize_t show_tallies(struct device *d, struct device_attribute *attr,
     CFG_HERMES_TALLIES_STRCT tallies;
     ssize_t ret = -EINVAL;
 
-    read_lock(&dev_base_lock);
+    rcu_read_lock();
     if (dev_isalive(dev)) {
 	wl_lock(lp, &flags);
 
@@ -102,7 +102,7 @@ static ssize_t show_tallies(struct device *d, struct device_attribute *attr,
 	    }
     }
 
-    read_unlock(&dev_base_lock);
+    rcu_read_unlock();
     return ret;
 }
 


