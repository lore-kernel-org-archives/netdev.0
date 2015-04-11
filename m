From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 12/17] kafs: Add more "unified AFS" error codes
Date: Sat, 11 Apr 2015 22:18:23 +0100
Message-ID: <1428787108-13650-12-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37879 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932576AbbDKVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:30 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathaniel Wesley Filardo <nwf@cs.jhu.edu>

This should cover the set emitted by viced and the volume server.

Signed-off-by: Nathaniel Wesley Filardo <nwf@cs.jhu.edu>
Signed-off-by: David Howells <dhowells@redhat.com>
---
 fs/afs/misc.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/afs/misc.c b/fs/afs/misc.c
index 0dd4daf..91ea1aa 100644
--- a/fs/afs/misc.c
+++ b/fs/afs/misc.c
@@ -22,9 +22,12 @@
 int afs_abort_to_error(u32 abort_code)
 {
 	switch (abort_code) {
+	/* low errno codes inserted into abort namespace */
 	case 13:		return -EACCES;
 	case 27:		return -EFBIG;
 	case 30:		return -EROFS;
+
+	/* VICE "special error" codes; 101 - 111 */
 	case VSALVAGE:		return -EIO;
 	case VNOVNODE:		return -ENOENT;
 	case VNOVOL:		return -ENOMEDIUM;
@@ -36,11 +39,18 @@ int afs_abort_to_error(u32 abort_code)
 	case VOVERQUOTA:	return -EDQUOT;
 	case VBUSY:		return -EBUSY;
 	case VMOVED:		return -ENXIO;
-	case 0x2f6df0a:		return -EWOULDBLOCK;
+
+	/* Unified AFS error table; ET "uae" == 0x2f6df00 */
+	case 0x2f6df00:		return -EPERM;
+	case 0x2f6df01:		return -ENOENT;
+	case 0x2f6df04:		return -EIO;
+	case 0x2f6df0a:		return -EAGAIN;
+	case 0x2f6df0b:		return -ENOMEM;
 	case 0x2f6df0c:		return -EACCES;
 	case 0x2f6df0f:		return -EBUSY;
 	case 0x2f6df10:		return -EEXIST;
 	case 0x2f6df11:		return -EXDEV;
+	case 0x2f6df12:		return -ENODEV;
 	case 0x2f6df13:		return -ENOTDIR;
 	case 0x2f6df14:		return -EISDIR;
 	case 0x2f6df15:		return -EINVAL;
@@ -54,8 +64,12 @@ int afs_abort_to_error(u32 abort_code)
 	case 0x2f6df23:		return -ENAMETOOLONG;
 	case 0x2f6df24:		return -ENOLCK;
 	case 0x2f6df26:		return -ENOTEMPTY;
+	case 0x2f6df28:		return -EWOULDBLOCK;
+	case 0x2f6df69:		return -ENOTCONN;
+	case 0x2f6df6c:		return -ETIMEDOUT;
 	case 0x2f6df78:		return -EDQUOT;
 
+	/* RXKAD abort codes; from include/rxrpc/packet.h.  ET "RXK" == 0x1260B00 */
 	case RXKADINCONSISTENCY: return -EPROTO;
 	case RXKADPACKETSHORT:	return -EPROTO;
 	case RXKADLEVELFAIL:	return -EKEYREJECTED;
-- 
2.1.4
