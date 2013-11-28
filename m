From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] diag: fix netlink API attributes
Date: Thu, 28 Nov 2013 14:57:19 +0100
Message-ID: <1385647039-1547-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:47680 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757435Ab3K1N5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 08:57:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first netlink attribute (value 0) must always be defined as none/unspec.
This is correctly done in inet_diag.h, but other diag interfaces are broken.

Libraries like libnl skip this kind of attributes, thus it's never reported to
the application.

CC: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Ok, I know that this patch change the API, but it's really painful to have such
broken API, is it really mandatory to live with this?
And the question is: how to avoid to have the same mistake in the next diag API?

 include/uapi/linux/netlink_diag.h | 1 +
 include/uapi/linux/packet_diag.h  | 1 +
 include/uapi/linux/unix_diag.h    | 1 +
 3 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
index 4e31db4eea41..d15d5c8f9d9c 100644
--- a/include/uapi/linux/netlink_diag.h
+++ b/include/uapi/linux/netlink_diag.h
@@ -33,6 +33,7 @@ struct netlink_diag_ring {
 };
 
 enum {
+	NETLINK_DIAG_NONE,
 	NETLINK_DIAG_MEMINFO,
 	NETLINK_DIAG_GROUPS,
 	NETLINK_DIAG_RX_RING,
diff --git a/include/uapi/linux/packet_diag.h b/include/uapi/linux/packet_diag.h
index b2cc0cd9c4d9..e49fa94b3463 100644
--- a/include/uapi/linux/packet_diag.h
+++ b/include/uapi/linux/packet_diag.h
@@ -29,6 +29,7 @@ struct packet_diag_msg {
 };
 
 enum {
+	PACKET_DIAG_UNSPEC,
 	PACKET_DIAG_INFO,
 	PACKET_DIAG_MCLIST,
 	PACKET_DIAG_RX_RING,
diff --git a/include/uapi/linux/unix_diag.h b/include/uapi/linux/unix_diag.h
index b9e2a6a7446f..b24e9626c704 100644
--- a/include/uapi/linux/unix_diag.h
+++ b/include/uapi/linux/unix_diag.h
@@ -31,6 +31,7 @@ struct unix_diag_msg {
 };
 
 enum {
+	UNIX_DIAG_NONE,
 	UNIX_DIAG_NAME,
 	UNIX_DIAG_VFS,
 	UNIX_DIAG_PEER,
-- 
1.8.4.1
