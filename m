From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/3] KEYS: Define an error code to indicate an authentication
 service was unavailable
Date: Thu, 03 Mar 2011 17:49:43 +0000
Message-ID: <20110303174943.21635.68646.stgit@warthog.procyon.org.uk>
References: <20110303174934.21635.18601.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
To: linux-security-module@vger.kernel.org, keyrings@linux-nfs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932246Ab1CCRtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 12:49:47 -0500
In-Reply-To: <20110303174934.21635.18601.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the kernel has or will have filesystems (and possibly other services) that
want to obtain authentication tokens and/or encryption data on demand (via
GSSAPI for example), it would seem useful to provide an additional error code
to indicate a problem with the lookup, rather than overloading some other error
code.

We already have EKEYREJECTED, EKEYREVOKED and EKEYEXPIRED to indicate problems
with a token that we already have, but what if the authentication server just
isn't available?

Define ENOAUTHSERVICE to indicate "Authentication service unavailable".  This
can be used to indicate, for example, that an attempt was made by request_key()
to retrieve a key, but the authentication server (e.g. a KDC) it is supposed to
contact didn't answer or that it couldn't determine the location of a suitable
server.

One way this can be used is that the user of a network filesystem can get a TGT
from the KDC and stash it in their session keyring, then the filesystem can
attempt to automatically get a ticket for accessing the filesystem - but if the
server is uncontactable then the ticket can be negatively instantiated with
KEYCTL_REJECT, giving the error to be handed to future requests as
ENOAUTHSERVICE and a small timeout so that the key will expire from the cache
and allow a retry after a short while to prevent thrashing.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/alpha/include/asm/errno.h  |    1 +
 arch/mips/include/asm/errno.h   |    1 +
 arch/parisc/include/asm/errno.h |    1 +
 arch/sparc/include/asm/errno.h  |    1 +
 include/asm-generic/errno.h     |    1 +
 5 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/arch/alpha/include/asm/errno.h b/arch/alpha/include/asm/errno.h
index 98099bd..519663c 100644
--- a/arch/alpha/include/asm/errno.h
+++ b/arch/alpha/include/asm/errno.h
@@ -121,5 +121,6 @@
 #define	ENOTRECOVERABLE	137	/* State not recoverable */
 
 #define	ERFKILL		138	/* Operation not possible due to RF-kill */
+#define	ENOAUTHSERVICE	139	/* Authentication service not available */
 
 #endif
diff --git a/arch/mips/include/asm/errno.h b/arch/mips/include/asm/errno.h
index a0efc73..5fa7fed 100644
--- a/arch/mips/include/asm/errno.h
+++ b/arch/mips/include/asm/errno.h
@@ -120,6 +120,7 @@
 #define	ENOTRECOVERABLE	166	/* State not recoverable */
 
 #define	ERFKILL		167	/* Operation not possible due to RF-kill */
+#define	ENOAUTHSERVICE	168	/* Authentication service not available */
 
 #define EDQUOT		1133	/* Quota exceeded */
 
diff --git a/arch/parisc/include/asm/errno.h b/arch/parisc/include/asm/errno.h
index 9992abd..6a19346 100644
--- a/arch/parisc/include/asm/errno.h
+++ b/arch/parisc/include/asm/errno.h
@@ -121,5 +121,6 @@
 #define ENOTRECOVERABLE	255	/* State not recoverable */
 
 #define	ERFKILL		256	/* Operation not possible due to RF-kill */
+#define	ENOAUTHSERVICE	257	/* Authentication service not available */
 
 #endif
diff --git a/arch/sparc/include/asm/errno.h b/arch/sparc/include/asm/errno.h
index 4e2bc49..ab3a26a 100644
--- a/arch/sparc/include/asm/errno.h
+++ b/arch/sparc/include/asm/errno.h
@@ -111,5 +111,6 @@
 #define	ENOTRECOVERABLE	133	/* State not recoverable */
 
 #define	ERFKILL		134	/* Operation not possible due to RF-kill */
+#define	ENOAUTHSERVICE	135	/* Authentication service not available */
 
 #endif
diff --git a/include/asm-generic/errno.h b/include/asm-generic/errno.h
index 28cc03b..bcf1908 100644
--- a/include/asm-generic/errno.h
+++ b/include/asm-generic/errno.h
@@ -107,5 +107,6 @@
 #define	ENOTRECOVERABLE	131	/* State not recoverable */
 
 #define ERFKILL		132	/* Operation not possible due to RF-kill */
+#define	ENOAUTHSERVICE	133	/* Authentication service not available */
 
 #endif

