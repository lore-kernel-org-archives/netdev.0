From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] sock: only define socket limit if mem cgroup configured
Date: Fri, 22 Feb 2013 09:59:10 -0800
Message-ID: <20130222095910.3ce8074b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:46481 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757866Ab3BVR7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 12:59:33 -0500
Received: by mail-pb0-f45.google.com with SMTP id ro8so529265pbb.32
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 09:59:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mem cgroup socket limit is only used if the config option is
enabled. Found with sparse

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/core/sock.c	2013-02-21 13:52:10.000000000 -0800
+++ b/net/core/sock.c	2013-02-21 21:03:06.075605811 -0800
@@ -186,8 +186,10 @@ void mem_cgroup_sockets_destroy(struct m
 static struct lock_class_key af_family_keys[AF_MAX];
 static struct lock_class_key af_family_slock_keys[AF_MAX];
 
+#if defined(CONFIG_MEMCG_KMEM)
 struct static_key memcg_socket_limit_enabled;
 EXPORT_SYMBOL(memcg_socket_limit_enabled);
+#endif
 
 /*
  * Make lock validator output more readable. (we pre-construct these
