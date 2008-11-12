From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] lockdep: silence warnings
Date: Wed, 12 Nov 2008 14:36:46 +0300
Message-ID: <20081112113646.GA4629@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:4255 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbYKLLdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 06:33:24 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1013850ugf.37
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 03:33:22 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/bluetooth/af_bluetooth.c:57: warning: 'bt_key_strings' defined but not used
net/bluetooth/af_bluetooth.c:68: warning: 'bt_slock_key_strings' defined but not used

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/lockdep.h |    4 ++--
 net/core/sock.c         |    2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -331,10 +331,10 @@ static inline void lockdep_on(void)
 # define lock_set_subclass(l, s, i)		do { } while (0)
 # define lockdep_init()				do { } while (0)
 # define lockdep_info()				do { } while (0)
-# define lockdep_init_map(lock, name, key, sub)	do { (void)(key); } while (0)
+# define lockdep_init_map(lock, name, key, sub)	do { (void)(name); (void)(key); } while (0)
 # define lockdep_set_class(lock, key)		do { (void)(key); } while (0)
 # define lockdep_set_class_and_name(lock, key, name) \
-		do { (void)(key); } while (0)
+		do { (void)(key); (void)(name); } while (0)
 #define lockdep_set_class_and_subclass(lock, key, sub) \
 		do { (void)(key); } while (0)
 #define lockdep_set_subclass(lock, sub)		do { } while (0)
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -136,7 +136,6 @@
 static struct lock_class_key af_family_keys[AF_MAX];
 static struct lock_class_key af_family_slock_keys[AF_MAX];
 
-#ifdef CONFIG_DEBUG_LOCK_ALLOC
 /*
  * Make lock validator output more readable. (we pre-construct these
  * strings build-time, so that runtime initialization of socket
@@ -187,7 +186,6 @@ static const char *af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_MAX"
 };
-#endif
 
 /*
  * sk_callback_lock locking rules are per-address-family,
