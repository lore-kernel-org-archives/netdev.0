From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 04/15] userns: net: Call key_alloc with GLOBAL_ROOT_UID, GLOBAL_ROOT_GID instead of 0, 0
Date: Sat, 25 Aug 2012 17:00:11 -0700
Message-ID: <87wr0mfrp0.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: Sage Weil <sage@inktank.com>
Cc: ceph-devel@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>
Cc: David Miller <davem@davemloft.net>
Cc: linux-afs@lists.infradead.org
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 088e7f2778bd228a4ce05f8dfaa4eb999e2207d2 Mon Sep 17 00:00:00 2001
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Fri, 25 May 2012 16:37:54 -0600
Subject: 

In net/dns_resolver/dns_key.c and net/rxrpc/ar-key.c make them
work with user namespaces enabled where key_alloc takes kuids and kgids.
Pass GLOBAL_ROOT_UID and GLOBAL_ROOT_GID instead of bare 0's.

Cc: Sage Weil <sage@inktank.com>
Cc: ceph-devel@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>
Cc: David Miller <davem@davemloft.net>
Cc: linux-afs@lists.infradead.org
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 init/Kconfig               |    2 --
 net/dns_resolver/dns_key.c |    3 ++-
 net/rxrpc/ar-key.c         |    6 ++++--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index d7f73bb..28715ec 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -941,8 +941,6 @@ config UIDGID_CONVERTED
 
 	# Networking
 	depends on NET_9P = n
-	depends on AF_RXRPC = n
-	depends on DNS_RESOLVER = n
 
 	# Filesystems
 	depends on USB_GADGETFS = n
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index d9507dd..9807945 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -259,7 +259,8 @@ static int __init init_dns_resolver(void)
 	if (!cred)
 		return -ENOMEM;
 
-	keyring = key_alloc(&key_type_keyring, ".dns_resolver", 0, 0, cred,
+	keyring = key_alloc(&key_type_keyring, ".dns_resolver",
+			    GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
 			    (KEY_POS_ALL & ~KEY_POS_SETATTR) |
 			    KEY_USR_VIEW | KEY_USR_READ,
 			    KEY_ALLOC_NOT_IN_QUOTA);
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index 8b1f9f4..011d238 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -948,7 +948,8 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
 
 	_enter("");
 
-	key = key_alloc(&key_type_rxrpc, "x", 0, 0, cred, 0,
+	key = key_alloc(&key_type_rxrpc, "x",
+			GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred, 0,
 			KEY_ALLOC_NOT_IN_QUOTA);
 	if (IS_ERR(key)) {
 		_leave(" = -ENOMEM [alloc %ld]", PTR_ERR(key));
@@ -994,7 +995,8 @@ struct key *rxrpc_get_null_key(const char *keyname)
 	struct key *key;
 	int ret;
 
-	key = key_alloc(&key_type_rxrpc, keyname, 0, 0, cred,
+	key = key_alloc(&key_type_rxrpc, keyname,
+			GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
 			KEY_POS_SEARCH, KEY_ALLOC_NOT_IN_QUOTA);
 	if (IS_ERR(key))
 		return key;
-- 
1.7.5.4
