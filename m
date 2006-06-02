From: akpm@osdl.org
Subject: [patch 07/17] secmark: Add new flask definitions to SELinux
Date: Thu, 01 Jun 2006 20:32:28 -0700
Message-ID: <200606020328.k523S9sm028823@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64436 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751204AbWFBD2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:16 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: James Morris <jmorris@namei.org>

Secmark implements a new scheme for adding security markings to packets via
iptables, as well as changes to SELinux to use these markings for security
policy enforcement.  The rationale for this scheme is explained and discussed
in detail in the original threads: 

 http://thread.gmane.org/gmane.linux.network/34927/ 
 http://thread.gmane.org/gmane.linux.network/35244/

Examples of policy and rulesets, as well as a full archive of patches for
iptables and SELinux userland, may be found at:
http://people.redhat.com/jmorris/selinux/secmark/

The code has been tested with various compilation options and in several
scenarios, including with 'complicated' protocols such as FTP and also with
the new generic conntrack code with IPv6 connection tracking.



This patch:

Add support for a new object class ('packet'), and associated permissions
('send', 'recv', 'relabelto').  These are used to enforce security policy for
network packets labeled with SECMARK, and for adding labeling rules.

Signed-off-by: James Morris <jmorris@namei.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 security/selinux/include/av_perm_to_string.h |    3 +++
 security/selinux/include/av_permissions.h    |    3 +++
 security/selinux/include/class_to_string.h   |    1 +
 security/selinux/include/flask.h             |    1 +
 4 files changed, 8 insertions(+)

diff -puN security/selinux/include/av_permissions.h~secmark-add-new-flask-definitions-to-selinux security/selinux/include/av_permissions.h
--- devel/security/selinux/include/av_permissions.h~secmark-add-new-flask-definitions-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/include/av_permissions.h	2006-06-01 20:31:50.000000000 -0700
@@ -956,3 +956,6 @@
 #define APPLETALK_SOCKET__SEND_MSG                0x00100000UL
 #define APPLETALK_SOCKET__NAME_BIND               0x00200000UL
 
+#define PACKET__SEND                              0x00000001UL
+#define PACKET__RECV                              0x00000002UL
+#define PACKET__RELABELTO                         0x00000004UL
diff -puN security/selinux/include/av_perm_to_string.h~secmark-add-new-flask-definitions-to-selinux security/selinux/include/av_perm_to_string.h
--- devel/security/selinux/include/av_perm_to_string.h~secmark-add-new-flask-definitions-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/include/av_perm_to_string.h	2006-06-01 20:31:50.000000000 -0700
@@ -239,3 +239,6 @@
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SENDTO, "sendto")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__RECVFROM, "recvfrom")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SETCONTEXT, "setcontext")
+   S_(SECCLASS_PACKET, PACKET__SEND, "send")
+   S_(SECCLASS_PACKET, PACKET__RECV, "recv")
+   S_(SECCLASS_PACKET, PACKET__RELABELTO, "relabelto")
diff -puN security/selinux/include/class_to_string.h~secmark-add-new-flask-definitions-to-selinux security/selinux/include/class_to_string.h
--- devel/security/selinux/include/class_to_string.h~secmark-add-new-flask-definitions-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/include/class_to_string.h	2006-06-01 20:31:50.000000000 -0700
@@ -59,3 +59,4 @@
     S_("association")
     S_("netlink_kobject_uevent_socket")
     S_("appletalk_socket")
+    S_("packet")
diff -puN security/selinux/include/flask.h~secmark-add-new-flask-definitions-to-selinux security/selinux/include/flask.h
--- devel/security/selinux/include/flask.h~secmark-add-new-flask-definitions-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/include/flask.h	2006-06-01 20:31:50.000000000 -0700
@@ -61,6 +61,7 @@
 #define SECCLASS_ASSOCIATION                             54
 #define SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET           55
 #define SECCLASS_APPLETALK_SOCKET                        56
+#define SECCLASS_PACKET                                  57
 
 /*
  * Security identifier indices for initial entities
_
