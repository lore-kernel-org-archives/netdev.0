From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH v2] diag: warn about missing first netlink attribute
Date: Thu, 28 Nov 2013 18:31:05 +0100
Message-ID: <1385659865-1926-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20131128163816.GA32047@casper.infradead.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:48416 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758916Ab3K1RbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 12:31:19 -0500
In-Reply-To: <20131128163816.GA32047@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first netlink attribute (value 0) must always be defined as none/unspec.
This is correctly done in inet_diag.h, but other diag interfaces are wrong.

Because we cannot change an existing API, I add a comment to point the mistake
and avoid to propagate it in a new diag API in the future.

CC: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: just warn about the missing attribute

If patch is approved, I will submit it when the net-next tree opens.

 include/uapi/linux/netlink_diag.h | 1 +
 include/uapi/linux/packet_diag.h  | 1 +
 include/uapi/linux/unix_diag.h    | 1 +
 3 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
index 4e31db4eea41..f2159d30d1f5 100644
--- a/include/uapi/linux/netlink_diag.h
+++ b/include/uapi/linux/netlink_diag.h
@@ -33,6 +33,7 @@ struct netlink_diag_ring {
 };
 
 enum {
+	/* NETLINK_DIAG_NONE, standard nl API requires this attribute!  */
 	NETLINK_DIAG_MEMINFO,
 	NETLINK_DIAG_GROUPS,
 	NETLINK_DIAG_RX_RING,
diff --git a/include/uapi/linux/packet_diag.h b/include/uapi/linux/packet_diag.h
index b2cc0cd9c4d9..d08c63f3dd6f 100644
--- a/include/uapi/linux/packet_diag.h
+++ b/include/uapi/linux/packet_diag.h
@@ -29,6 +29,7 @@ struct packet_diag_msg {
 };
 
 enum {
+	/* PACKET_DIAG_NONE, standard nl API requires this attribute!  */
 	PACKET_DIAG_INFO,
 	PACKET_DIAG_MCLIST,
 	PACKET_DIAG_RX_RING,
diff --git a/include/uapi/linux/unix_diag.h b/include/uapi/linux/unix_diag.h
index b9e2a6a7446f..1eb0b8dd1830 100644
--- a/include/uapi/linux/unix_diag.h
+++ b/include/uapi/linux/unix_diag.h
@@ -31,6 +31,7 @@ struct unix_diag_msg {
 };
 
 enum {
+	/* UNIX_DIAG_NONE, standard nl API requires this attribute!  */
 	UNIX_DIAG_NAME,
 	UNIX_DIAG_VFS,
 	UNIX_DIAG_PEER,
-- 
1.8.4.1
