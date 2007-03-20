From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/5] AF_RXRPC: Key facility changes for AF_RXRPC [try #3]
Date: Tue, 20 Mar 2007 19:59:19 +0000
Message-ID: <20070320195919.12853.63598.stgit@warthog.cambridge.redhat.com>
References: <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52596 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887AbXCTT7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 15:59:49 -0400
In-Reply-To: <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Export the keyring key type definition and document its availability.

Add alternative types into the key's type_data union to make it more useful.
Not all users necessarily want to use it as a list_head (AF_RXRPC doesn't, for
example), so make it clear that it can be used in other ways.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 Documentation/keys.txt  |   12 ++++++++++++
 include/linux/key.h     |    2 ++
 security/keys/keyring.c |    2 ++
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/Documentation/keys.txt b/Documentation/keys.txt
index 60c665d..81d9aa0 100644
--- a/Documentation/keys.txt
+++ b/Documentation/keys.txt
@@ -859,6 +859,18 @@ payload contents" for more information.
 	void unregister_key_type(struct key_type *type);
 
 
+Under some circumstances, it may be desirable to desirable to deal with a
+bundle of keys.  The facility provides access to the keyring type for managing
+such a bundle:
+
+	struct key_type key_type_keyring;
+
+This can be used with a function such as request_key() to find a specific
+keyring in a process's keyrings.  A keyring thus found can then be searched
+with keyring_search().  Note that it is not possible to use request_key() to
+search a specific keyring, so using keyrings in this way is of limited utility.
+
+
 ===================================
 NOTES ON ACCESSING PAYLOAD CONTENTS
 ===================================
diff --git a/include/linux/key.h b/include/linux/key.h
index 169f05e..a9220e7 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -160,6 +160,8 @@ struct key {
 	 */
 	union {
 		struct list_head	link;
+		unsigned long		x[2];
+		void			*p[2];
 	} type_data;
 
 	/* key data
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index ad45ce7..88292e3 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -66,6 +66,8 @@ struct key_type key_type_keyring = {
 	.read		= keyring_read,
 };
 
+EXPORT_SYMBOL(key_type_keyring);
+
 /*
  * semaphore to serialise link/link calls to prevent two link calls in parallel
  * introducing a cycle

