From: James Morris <jmorris@namei.org>
Subject: [PATCH 01/07] secmark: Add new flask definitions to SELinux
Date: Thu, 18 May 2006 05:22:46 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605180521060.569@d.namei>
References: <Pine.LNX.4.64.0605180458130.569@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	Karl MacMillan <kmacmillan@tresys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:50127 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751025AbWERJWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 05:22:48 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605180458130.569@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for a new object class ('packet'), and associated 
permissions ('send', 'recv', 'relabelto').  These are used to enforce 
security policy for network packets labeled with SECMARK, and for adding 
labeling rules.

Please apply.

Signed-off-by: James Morris <jmorris@namei.org>

---

 security/selinux/include/av_perm_to_string.h |    3 +++
 security/selinux/include/av_permissions.h    |    3 +++
 security/selinux/include/class_to_string.h   |    1 +
 security/selinux/include/flask.h             |    1 +
 4 files changed, 8 insertions(+)

diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/include/av_permissions.h linux-2.6.17-rc4-mm1.w/security/selinux/include/av_permissions.h
--- linux-2.6.17-rc4-mm1.p/security/selinux/include/av_permissions.h	2006-05-16 23:35:11.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/security/selinux/include/av_permissions.h	2006-05-17 01:13:15.000000000 -0400
@@ -956,3 +956,6 @@
 #define APPLETALK_SOCKET__SEND_MSG                0x00100000UL
 #define APPLETALK_SOCKET__NAME_BIND               0x00200000UL
 
+#define PACKET__SEND                              0x00000001UL
+#define PACKET__RECV                              0x00000002UL
+#define PACKET__RELABELTO                         0x00000004UL
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/include/av_perm_to_string.h linux-2.6.17-rc4-mm1.w/security/selinux/include/av_perm_to_string.h
--- linux-2.6.17-rc4-mm1.p/security/selinux/include/av_perm_to_string.h	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.17-rc4-mm1.w/security/selinux/include/av_perm_to_string.h	2006-05-17 01:13:33.000000000 -0400
@@ -239,3 +239,6 @@
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SENDTO, "sendto")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__RECVFROM, "recvfrom")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SETCONTEXT, "setcontext")
+   S_(SECCLASS_PACKET, PACKET__SEND, "send")
+   S_(SECCLASS_PACKET, PACKET__RECV, "recv")
+   S_(SECCLASS_PACKET, PACKET__RELABELTO, "relabelto")
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/include/class_to_string.h linux-2.6.17-rc4-mm1.w/security/selinux/include/class_to_string.h
--- linux-2.6.17-rc4-mm1.p/security/selinux/include/class_to_string.h	2006-05-16 23:35:11.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/security/selinux/include/class_to_string.h	2006-05-17 01:10:46.000000000 -0400
@@ -59,3 +59,4 @@
     S_("association")
     S_("netlink_kobject_uevent_socket")
     S_("appletalk_socket")
+    S_("packet")
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/include/flask.h linux-2.6.17-rc4-mm1.w/security/selinux/include/flask.h
--- linux-2.6.17-rc4-mm1.p/security/selinux/include/flask.h	2006-05-16 23:35:11.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/security/selinux/include/flask.h	2006-05-17 01:09:43.000000000 -0400
@@ -61,6 +61,7 @@
 #define SECCLASS_ASSOCIATION                             54
 #define SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET           55
 #define SECCLASS_APPLETALK_SOCKET                        56
+#define SECCLASS_PACKET                                  57
 
 /*
  * Security identifier indices for initial entities
