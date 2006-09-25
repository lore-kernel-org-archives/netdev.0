From: paul.moore@hp.com
Subject: [PATCH v2 3/8] NetLabel: change the SELinux permissions
Date: Mon, 25 Sep 2006 14:04:15 -0400
Message-ID: <20060925180640.679073000@hp.com>
References: <20060925180412.715069000@hp.com>
Cc: tgraf@suug.ch, jmorris@redhat.com, sds@epoch.ncsc.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:32955 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1751418AbWIYSGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 14:06:43 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
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
