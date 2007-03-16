From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/5] AF_RXRPC: Key facility changes for AF_RXRPC [try #2]
Date: Fri, 16 Mar 2007 12:50:31 +0000
Message-ID: <20070316125031.3740.36610.stgit@warthog.cambridge.redhat.com>
References: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932078AbXCPMuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 08:50:44 -0400
In-Reply-To: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Export the keyring key type definition.

Add extra alternative types into the key's type_data union to make it more
useful.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 include/linux/key.h     |    2 ++
 security/keys/keyring.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

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

