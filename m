From: paul.moore@hp.com
Subject: [PATCH 3/6] NetLabel: change the SELinux permissions
Date: Thu, 21 Sep 2006 12:57:06 -0400
Message-ID: <20060921170336.334044000@hp.com>
References: <20060921165703.251871000@hp.com>
Cc: sds@epoch.ncsc.mil, jmorris@redhat.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:9603 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1751358AbWIURDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 13:03:41 -0400
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org
Content-Disposition: inline; filename=netlabel-selinux_perm
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change NetLabel to use the 'recvfrom' socket permission and the
SECINITSID_NETMSG SELinux SID as the NetLabel base SID for incoming packets.
This patch effectively makes the old, and currently unused, SELinux NETMSG
permissions NetLabel permissions.

Signed-of-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/ss/services.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

Index: net-2.6.19/security/selinux/ss/services.c
===================================================================
--- net-2.6.19.orig/security/selinux/ss/services.c
+++ net-2.6.19/security/selinux/ss/services.c
@@ -2611,7 +2611,7 @@ int selinux_netlbl_sock_rcv_skb(struct s
 	u32 netlbl_sid;
 	u32 recv_perm;
 
-	rc = selinux_netlbl_skbuff_getsid(skb, sksec->sid, &netlbl_sid);
+	rc = selinux_netlbl_skbuff_getsid(skb, SECINITSID_NETMSG, &netlbl_sid);
 	if (rc != 0)
 		return rc;
 
@@ -2620,13 +2620,13 @@ int selinux_netlbl_sock_rcv_skb(struct s
 
 	switch (sksec->sclass) {
 	case SECCLASS_UDP_SOCKET:
-		recv_perm = UDP_SOCKET__RECV_MSG;
+		recv_perm = UDP_SOCKET__RECVFROM;
 		break;
 	case SECCLASS_TCP_SOCKET:
-		recv_perm = TCP_SOCKET__RECV_MSG;
+		recv_perm = TCP_SOCKET__RECVFROM;
 		break;
 	default:
-		recv_perm = RAWIP_SOCKET__RECV_MSG;
+		recv_perm = RAWIP_SOCKET__RECVFROM;
 	}
 
 	rc = avc_has_perm(sksec->sid,

--
paul moore
linux security @ hp
