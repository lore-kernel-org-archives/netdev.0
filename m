From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [patch 2/4] lockdep: fixup sk_callback_lock annotation
Date: Tue, 12 Jun 2007 14:13:53 +0200
Message-ID: <20070612121916.590506722@chello.nl>
References: <20070612121351.448814658@chello.nl>
Cc: Bill Huey <billh@gnuppy.monkey.org>,
	Jason Baron <jbaron@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Christoph Hellwig <hch@infradead.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:54304 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756126AbXFLNH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 09:07:28 -0400
Content-Disposition: inline; filename=lockdep_fixup_annotate.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the two init sites resulted in inconsistend names for the lock class.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Ingo Molnar <mingo@elte.hu>
Cc: netdev@vger.kernel.org
---
 net/core/sock.c |   23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

Index: linux-2.6/net/core/sock.c
===================================================================
--- linux-2.6.orig/net/core/sock.c
+++ linux-2.6/net/core/sock.c
@@ -171,6 +171,19 @@ static const char *af_family_slock_key_s
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_MAX"
 };
+static const char *af_family_clock_key_strings[AF_MAX+1] = {
+  "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
+  "clock-AF_AX25"  , "clock-AF_IPX"      , "clock-AF_APPLETALK",
+  "clock-AF_NETROM", "clock-AF_BRIDGE"   , "clock-AF_ATMPVC"   ,
+  "clock-AF_X25"   , "clock-AF_INET6"    , "clock-AF_ROSE"     ,
+  "clock-AF_DECnet", "clock-AF_NETBEUI"  , "clock-AF_SECURITY" ,
+  "clock-AF_KEY"   , "clock-AF_NETLINK"  , "clock-AF_PACKET"   ,
+  "clock-AF_ASH"   , "clock-AF_ECONET"   , "clock-AF_ATMSVC"   ,
+  "clock-21"       , "clock-AF_SNA"      , "clock-AF_IRDA"     ,
+  "clock-AF_PPPOX" , "clock-AF_WANPIPE"  , "clock-AF_LLC"      ,
+  "clock-27"       , "clock-28"          , "clock-29"          ,
+  "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_MAX"
+};
 #endif
 
 /*
@@ -941,8 +954,9 @@ struct sock *sk_clone(const struct sock 
 
 		rwlock_init(&newsk->sk_dst_lock);
 		rwlock_init(&newsk->sk_callback_lock);
-		lockdep_set_class(&newsk->sk_callback_lock,
-				   af_callback_keys + newsk->sk_family);
+		lockdep_set_class_and_name(&newsk->sk_callback_lock,
+				af_callback_keys + newsk->sk_family,
+				af_family_clock_key_strings[newsk->sk_family]);
 
 		newsk->sk_dst_cache	= NULL;
 		newsk->sk_wmem_queued	= 0;
@@ -1530,8 +1544,9 @@ void sock_init_data(struct socket *sock,
 
 	rwlock_init(&sk->sk_dst_lock);
 	rwlock_init(&sk->sk_callback_lock);
-	lockdep_set_class(&sk->sk_callback_lock,
-			   af_callback_keys + sk->sk_family);
+	lockdep_set_class_and_name(&sk->sk_callback_lock,
+			af_callback_keys + sk->sk_family,
+			af_family_clock_key_strings[sk->sk_family]);
 
 	sk->sk_state_change	=	sock_def_wakeup;
 	sk->sk_data_ready	=	sock_def_readable;

-- 

