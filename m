From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [NET]: Add missing braces to multi-statement if()s
Date: Fri, 2 May 2008 16:48:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805021646000.30402@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-793373191-1209736115=:30402"
Cc: David Howells <dhowells@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59503 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756048AbYEBNsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 09:48:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-793373191-1209736115=:30402
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


One finds all kinds of crazy things with some shell pipelining.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Cc: David Howells <dhowells@redhat.com>
---
 net/core/sock.c          |    3 ++-
 net/rxrpc/ar-transport.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 5dbb81b..fa76f04 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -228,11 +228,12 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 		static int warned __read_mostly;
 
 		*timeo_p = 0;
-		if (warned < 10 && net_ratelimit())
+		if (warned < 10 && net_ratelimit()) {
 			warned++;
 			printk(KERN_INFO "sock_set_timeout: `%s' (pid %d) "
 			       "tries to set negative timeout\n",
 				current->comm, task_pid_nr(current));
+		}
 		return 0;
 	}
 	*timeo_p = MAX_SCHEDULE_TIMEOUT;
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index bb282a6..64069c8 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -184,12 +184,13 @@ void rxrpc_put_transport(struct rxrpc_transport *trans)
 	ASSERTCMP(atomic_read(&trans->usage), >, 0);
 
 	trans->put_time = get_seconds();
-	if (unlikely(atomic_dec_and_test(&trans->usage)))
+	if (unlikely(atomic_dec_and_test(&trans->usage))) {
 		_debug("zombie");
 		/* let the reaper determine the timeout to avoid a race with
 		 * overextending the timeout if the reaper is running at the
 		 * same time */
 		rxrpc_queue_delayed_work(&rxrpc_transport_reap, 0);
+	}
 	_leave("");
 }
 
-- 
1.5.2.2

---696208474-793373191-1209736115=:30402--
