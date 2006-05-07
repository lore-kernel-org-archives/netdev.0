From: James Morris <jmorris@namei.org>
Subject: [RFC][SECMARK 04/08] Add new flask definitions to SELinux
Date: Sun, 7 May 2006 11:36:03 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605071135240.8588@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:29601 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932177AbWEGPgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 11:36:10 -0400
To: selinux@tycho.nsa.gov
In-Reply-To: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for a new object class ('packet'),
and two associated permissions ('send', 'recv').  These
are used to enforce security policy for network packets
labeled with SECMARK.


Signed-off-by: James Morris <jmorris@namei.org>

---

diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/security/selinux/include/av_permissions.h linux-2.6.17-rc2-mm1.w/security/selinux/include/av_permissions.h
--- linux-2.6.17-rc2-mm1.p/security/selinux/include/av_permissions.h	2006-05-01 16:51:36.000000000 -0400
+++ linux-2.6.17-rc2-mm1.w/security/selinux/include/av_permissions.h	2006-05-01 16:52:14.000000000 -0400
@@ -933,3 +933,6 @@
 #define NETLINK_KOBJECT_UEVENT_SOCKET__SEND_MSG   0x00100000UL
 #define NETLINK_KOBJECT_UEVENT_SOCKET__NAME_BIND  0x00200000UL
 
+#define PACKET__SEND                              0x00000001UL
+#define PACKET__RECV                              0x00000002UL
+
diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/security/selinux/include/av_perm_to_string.h linux-2.6.17-rc2-mm1.w/security/selinux/include/av_perm_to_string.h
--- linux-2.6.17-rc2-mm1.p/security/selinux/include/av_perm_to_string.h	2006-05-01 16:51:36.000000000 -0400
+++ linux-2.6.17-rc2-mm1.w/security/selinux/include/av_perm_to_string.h	2006-05-01 16:52:14.000000000 -0400
@@ -239,3 +239,5 @@
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SENDTO, "sendto")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__RECVFROM, "recvfrom")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SETCONTEXT, "setcontext")
+   S_(SECCLASS_PACKET, PACKET__SEND, "send")
+   S_(SECCLASS_PACKET, PACKET__RECV, "recv")
diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/security/selinux/include/class_to_string.h linux-2.6.17-rc2-mm1.w/security/selinux/include/class_to_string.h
--- linux-2.6.17-rc2-mm1.p/security/selinux/include/class_to_string.h	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.17-rc2-mm1.w/security/selinux/include/class_to_string.h	2006-05-01 16:52:14.000000000 -0400
@@ -58,3 +58,4 @@
     S_("nscd")
     S_("association")
     S_("netlink_kobject_uevent_socket")
+    S_("packet")
diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/security/selinux/include/flask.h linux-2.6.17-rc2-mm1.w/security/selinux/include/flask.h
--- linux-2.6.17-rc2-mm1.p/security/selinux/include/flask.h	2006-05-01 16:51:36.000000000 -0400
+++ linux-2.6.17-rc2-mm1.w/security/selinux/include/flask.h	2006-05-01 16:52:14.000000000 -0400
@@ -60,6 +60,7 @@
 #define SECCLASS_NSCD                                    53
 #define SECCLASS_ASSOCIATION                             54
 #define SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET           55
+#define SECCLASS_PACKET                                  56
 
 /*
  * Security identifier indices for initial entities
