From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH 2/3] [RFC] net: introduce socket family constants
Date: Fri, 21 Nov 2014 21:08:03 +0100
Message-ID: <1416600484-55631-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1416600484-55631-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, davem@davemloft.net,
	utz.bacher@de.ibm.com, ogerlitz@mellanox.com, monis@mellanox.com,
	fowlerja@us.ibm.com, heiko.carstens@de.ibm.com,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:37998 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbaKUUIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:08:16 -0500
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 21 Nov 2014 20:08:15 -0000
In-Reply-To: <1416600484-55631-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The new socket family is assigned the next available address / protocol family
constant 41.

In addition some extra setsockopt handling is needed, which requires definition
of SMC-specific setsockopt level 281.

To support socket call splice_read in AF_SMC, exporting symbol splice_to_pipe
is needed.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 fs/splice.c            | 1 +
 include/linux/socket.h | 5 ++++-
 net/Makefile           | 1 +
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/splice.c b/fs/splice.c
index 75c6058..d09d843 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -262,6 +262,7 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 
 	return ret;
 }
+EXPORT_SYMBOL(splice_to_pipe);
 
 void spd_release_page(struct splice_pipe_desc *spd, unsigned int i)
 {
diff --git a/include/linux/socket.h b/include/linux/socket.h
index bb9b836..eb887ef 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -180,7 +180,8 @@ struct ucred {
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
 #define AF_VSOCK	40	/* vSockets			*/
-#define AF_MAX		41	/* For now.. */
+#define AF_SMC		41	/* smc sockets			*/
+#define AF_MAX		42	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -225,6 +226,7 @@ struct ucred {
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
 #define PF_VSOCK	AF_VSOCK
+#define PF_SMC		AF_SMC
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
@@ -301,6 +303,7 @@ struct ucred {
 #define SOL_CAIF	278
 #define SOL_ALG		279
 #define SOL_NFC		280
+#define SOL_SMC		281
 
 /* IPX options */
 #define IPX_TYPE	1
diff --git a/net/Makefile b/net/Makefile
index 7ed1970..851b1ce 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -51,6 +51,7 @@ obj-$(CONFIG_MAC80211)		+= mac80211/
 obj-$(CONFIG_TIPC)		+= tipc/
 obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
+obj-$(CONFIG_AFSMC)		+= smc/
 obj-$(CONFIG_RFKILL)		+= rfkill/
 obj-$(CONFIG_NET_9P)		+= 9p/
 obj-$(CONFIG_CAIF)		+= caif/
-- 
1.8.5.5
