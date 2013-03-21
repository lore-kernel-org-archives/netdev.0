From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] unix_diag: Fix definition of UNIX_DIAG_MAX
Date: Thu, 21 Mar 2013 14:17:00 +0100
Message-ID: <7c4a72239f4795677484c99c105ef5f27c12d246.1363871797.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:35155 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756333Ab3CUNRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 09:17:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UNIX_DIAG_MAX should point to the maximum attribute type known
instead of + 1. User space applications compiled against the
old definition are currently passing through unknown attribute
types while parsing.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/uapi/linux/unix_diag.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/unix_diag.h b/include/uapi/linux/unix_diag.h
index b8a2494..387aab0 100644
--- a/include/uapi/linux/unix_diag.h
+++ b/include/uapi/linux/unix_diag.h
@@ -38,10 +38,11 @@ enum {
 	UNIX_DIAG_RQLEN,
 	UNIX_DIAG_MEMINFO,
 	UNIX_DIAG_SHUTDOWN,
-
-	UNIX_DIAG_MAX,
+	__UNIX_DIAG_MAX,
 };
 
+#define UNIX_DIAG_MAX (__UNIX_DIAG_MAX - 1)
+
 struct unix_diag_vfs {
 	__u32	udiag_vfs_ino;
 	__u32	udiag_vfs_dev;
-- 
1.7.11.7
