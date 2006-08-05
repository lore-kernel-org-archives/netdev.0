From: Thomas Graf <tgraf@suug.ch>
Subject: [SELinux]: selinux_socket_getpeersec_dgram() compile fix
Date: Sat, 5 Aug 2006 13:56:20 +0200
Message-ID: <20060805115620.GO14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, cxzhang@watson.ibm.com, jmorris@namei.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:39564 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1161284AbWHELz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2006 07:55:59 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Collision between "[NetLabel]: SELinux support"  and
"[AF_UNIX]: Kernel memory leak fix for af_unix datagram getpeersec"

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/security/selinux/hooks.c
===================================================================
--- net-2.6.19.git.orig/security/selinux/hooks.c
+++ net-2.6.19.git/security/selinux/hooks.c
@@ -3556,9 +3556,9 @@ static int selinux_socket_getpeersec_dgr
 	if (sock && (sock->sk->sk_family == PF_UNIX))
 		selinux_get_inode_sid(SOCK_INODE(sock), &peer_secid);
 	else if (skb) {
-		peer_sid = selinux_netlbl_socket_getpeersec_dgram(skb);
-		if (peer_sid == SECSID_NULL)
-			peer_sid = selinux_socket_getpeer_dgram(skb);
+		peer_secid = selinux_netlbl_socket_getpeersec_dgram(skb);
+		if (peer_secid == SECSID_NULL)
+			peer_secid = selinux_socket_getpeer_dgram(skb);
 	}
 
 	if (peer_secid == SECSID_NULL)
