From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] net: fix *_DIAG_MAX constants
Date: Thu, 21 Mar 2013 18:18:20 +0400
Message-ID: <1363875500-14574-1-git-send-email-avagin@openvz.org>
Cc: Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <edumazet@google.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Howells <dhowells@redhat.com>
To: Thomas Graf <tgraf@suug.ch>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:40459 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757831Ab3CUOTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 10:19:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow the common pattern and define *_DIAG_MAX like:

        [...]
        __XXX_DIAG_MAX,
};

Because everyone is used to do:

        struct nlattr *attrs[XXX_DIAG_MAX+1];

        nla_parse([...], XXX_DIAG_MAX, [...]

Reported-by: Thomas Graf <tgraf@suug.ch>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: David Howells <dhowells@redhat.com>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/uapi/linux/netlink_diag.h | 4 +++-
 include/uapi/linux/packet_diag.h  | 4 +++-
 include/uapi/linux/unix_diag.h    | 4 +++-
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
index 9328866..88009a3 100644
--- a/include/uapi/linux/netlink_diag.h
+++ b/include/uapi/linux/netlink_diag.h
@@ -29,9 +29,11 @@ enum {
 	NETLINK_DIAG_MEMINFO,
 	NETLINK_DIAG_GROUPS,
 
-	NETLINK_DIAG_MAX,
+	__NETLINK_DIAG_MAX,
 };
 
+#define NETLINK_DIAG_MAX (__NETLINK_DIAG_MAX - 1)
+
 #define NDIAG_PROTO_ALL		((__u8) ~0)
 
 #define NDIAG_SHOW_MEMINFO	0x00000001 /* show memory info of a socket */
diff --git a/include/uapi/linux/packet_diag.h b/include/uapi/linux/packet_diag.h
index 93f5fa9..afafd70 100644
--- a/include/uapi/linux/packet_diag.h
+++ b/include/uapi/linux/packet_diag.h
@@ -33,9 +33,11 @@ enum {
 	PACKET_DIAG_TX_RING,
 	PACKET_DIAG_FANOUT,
 
-	PACKET_DIAG_MAX,
+	__PACKET_DIAG_MAX,
 };
 
+#define PACKET_DIAG_MAX (__PACKET_DIAG_MAX - 1)
+
 struct packet_diag_info {
 	__u32	pdi_index;
 	__u32	pdi_version;
diff --git a/include/uapi/linux/unix_diag.h b/include/uapi/linux/unix_diag.h
index b8a2494..b9e2a6a 100644
--- a/include/uapi/linux/unix_diag.h
+++ b/include/uapi/linux/unix_diag.h
@@ -39,9 +39,11 @@ enum {
 	UNIX_DIAG_MEMINFO,
 	UNIX_DIAG_SHUTDOWN,
 
-	UNIX_DIAG_MAX,
+	__UNIX_DIAG_MAX,
 };
 
+#define UNIX_DIAG_MAX (__UNIX_DIAG_MAX - 1)
+
 struct unix_diag_vfs {
 	__u32	udiag_vfs_ino;
 	__u32	udiag_vfs_dev;
-- 
1.8.1.4
