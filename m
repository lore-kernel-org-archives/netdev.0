From: akpm@osdl.org
Subject: [patch 05/17] selinux: add security class for appletalk sockets
Date: Thu, 01 Jun 2006 20:32:25 -0700
Message-ID: <200606020328.k523S6Bc028817@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, cpebenito@tresys.com,
	jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7605 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751206AbWFBD20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:26 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Christopher J. PeBenito <cpebenito@tresys.com>

Add a security class for appletalk sockets so that they can be
distinguished in SELinux policy.  Please apply.

Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
Acked-by: James Morris <jmorris@namei.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 security/selinux/hooks.c                   |    2 +
 security/selinux/include/av_inherit.h      |    1 
 security/selinux/include/av_permissions.h  |   23 +++++++++++++++++++
 security/selinux/include/class_to_string.h |    1 
 security/selinux/include/flask.h           |    1 
 5 files changed, 28 insertions(+)

diff -puN security/selinux/hooks.c~selinux-add-security-class-for-appletalk-sockets security/selinux/hooks.c
--- devel/security/selinux/hooks.c~selinux-add-security-class-for-appletalk-sockets	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/security/selinux/hooks.c	2006-06-01 20:31:49.000000000 -0700
@@ -696,6 +696,8 @@ static inline u16 socket_type_to_securit
 		return SECCLASS_PACKET_SOCKET;
 	case PF_KEY:
 		return SECCLASS_KEY_SOCKET;
+	case PF_APPLETALK:
+		return SECCLASS_APPLETALK_SOCKET;
 	}
 
 	return SECCLASS_SOCKET;
diff -puN security/selinux/include/av_inherit.h~selinux-add-security-class-for-appletalk-sockets security/selinux/include/av_inherit.h
--- devel/security/selinux/include/av_inherit.h~selinux-add-security-class-for-appletalk-sockets	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/security/selinux/include/av_inherit.h	2006-06-01 20:31:49.000000000 -0700
@@ -29,3 +29,4 @@
    S_(SECCLASS_NETLINK_IP6FW_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_NETLINK_DNRT_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET, socket, 0x00400000UL)
+   S_(SECCLASS_APPLETALK_SOCKET, socket, 0x00400000UL)
diff -puN security/selinux/include/av_permissions.h~selinux-add-security-class-for-appletalk-sockets security/selinux/include/av_permissions.h
--- devel/security/selinux/include/av_permissions.h~selinux-add-security-class-for-appletalk-sockets	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/security/selinux/include/av_permissions.h	2006-06-01 20:31:49.000000000 -0700
@@ -933,3 +933,26 @@
 #define NETLINK_KOBJECT_UEVENT_SOCKET__SEND_MSG   0x00100000UL
 #define NETLINK_KOBJECT_UEVENT_SOCKET__NAME_BIND  0x00200000UL
 
+#define APPLETALK_SOCKET__IOCTL                   0x00000001UL
+#define APPLETALK_SOCKET__READ                    0x00000002UL
+#define APPLETALK_SOCKET__WRITE                   0x00000004UL
+#define APPLETALK_SOCKET__CREATE                  0x00000008UL
+#define APPLETALK_SOCKET__GETATTR                 0x00000010UL
+#define APPLETALK_SOCKET__SETATTR                 0x00000020UL
+#define APPLETALK_SOCKET__LOCK                    0x00000040UL
+#define APPLETALK_SOCKET__RELABELFROM             0x00000080UL
+#define APPLETALK_SOCKET__RELABELTO               0x00000100UL
+#define APPLETALK_SOCKET__APPEND                  0x00000200UL
+#define APPLETALK_SOCKET__BIND                    0x00000400UL
+#define APPLETALK_SOCKET__CONNECT                 0x00000800UL
+#define APPLETALK_SOCKET__LISTEN                  0x00001000UL
+#define APPLETALK_SOCKET__ACCEPT                  0x00002000UL
+#define APPLETALK_SOCKET__GETOPT                  0x00004000UL
+#define APPLETALK_SOCKET__SETOPT                  0x00008000UL
+#define APPLETALK_SOCKET__SHUTDOWN                0x00010000UL
+#define APPLETALK_SOCKET__RECVFROM                0x00020000UL
+#define APPLETALK_SOCKET__SENDTO                  0x00040000UL
+#define APPLETALK_SOCKET__RECV_MSG                0x00080000UL
+#define APPLETALK_SOCKET__SEND_MSG                0x00100000UL
+#define APPLETALK_SOCKET__NAME_BIND               0x00200000UL
+
diff -puN security/selinux/include/class_to_string.h~selinux-add-security-class-for-appletalk-sockets security/selinux/include/class_to_string.h
--- devel/security/selinux/include/class_to_string.h~selinux-add-security-class-for-appletalk-sockets	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/security/selinux/include/class_to_string.h	2006-06-01 20:31:49.000000000 -0700
@@ -58,3 +58,4 @@
     S_("nscd")
     S_("association")
     S_("netlink_kobject_uevent_socket")
+    S_("appletalk_socket")
diff -puN security/selinux/include/flask.h~selinux-add-security-class-for-appletalk-sockets security/selinux/include/flask.h
--- devel/security/selinux/include/flask.h~selinux-add-security-class-for-appletalk-sockets	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/security/selinux/include/flask.h	2006-06-01 20:31:49.000000000 -0700
@@ -60,6 +60,7 @@
 #define SECCLASS_NSCD                                    53
 #define SECCLASS_ASSOCIATION                             54
 #define SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET           55
+#define SECCLASS_APPLETALK_SOCKET                        56
 
 /*
  * Security identifier indices for initial entities
_
