From: Joe Perches <joe@perches.com>
Subject: [PATCH 15/21] net/atm/pvc.c: checkpatch cleanups
Date: Tue, 26 Jan 2010 13:40:14 -0800
Message-ID: <2a6b96da4394e0b4c80fe7dc741bc48f15d90850.1264541549.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1488 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753974Ab0AZVkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:24 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spacing cleanups
Mostly 80 column wrapped.
Move trailing statements to new lines

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/pvc.c |   43 +++++++++++++++++++++----------------------
 1 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/net/atm/pvc.c b/net/atm/pvc.c
index 8d74e62..437ee70 100644
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -17,32 +17,35 @@
 #include "common.h"		/* common for PVCs and SVCs */
 
 
-static int pvc_shutdown(struct socket *sock,int how)
+static int pvc_shutdown(struct socket *sock, int how)
 {
 	return 0;
 }
 
-
-static int pvc_bind(struct socket *sock,struct sockaddr *sockaddr,
-    int sockaddr_len)
+static int pvc_bind(struct socket *sock, struct sockaddr *sockaddr,
+		    int sockaddr_len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_atmpvc *addr;
 	struct atm_vcc *vcc;
 	int error;
 
-	if (sockaddr_len != sizeof(struct sockaddr_atmpvc)) return -EINVAL;
-	addr = (struct sockaddr_atmpvc *) sockaddr;
-	if (addr->sap_family != AF_ATMPVC) return -EAFNOSUPPORT;
+	if (sockaddr_len != sizeof(struct sockaddr_atmpvc))
+		return -EINVAL;
+	addr = (struct sockaddr_atmpvc *)sockaddr;
+	if (addr->sap_family != AF_ATMPVC)
+		return -EAFNOSUPPORT;
 	lock_sock(sk);
 	vcc = ATM_SD(sock);
 	if (!test_bit(ATM_VF_HASQOS, &vcc->flags)) {
 		error = -EBADFD;
 		goto out;
 	}
-	if (test_bit(ATM_VF_PARTIAL,&vcc->flags)) {
-		if (vcc->vpi != ATM_VPI_UNSPEC) addr->sap_addr.vpi = vcc->vpi;
-		if (vcc->vci != ATM_VCI_UNSPEC) addr->sap_addr.vci = vcc->vci;
+	if (test_bit(ATM_VF_PARTIAL, &vcc->flags)) {
+		if (vcc->vpi != ATM_VPI_UNSPEC)
+			addr->sap_addr.vpi = vcc->vpi;
+		if (vcc->vci != ATM_VCI_UNSPEC)
+			addr->sap_addr.vci = vcc->vci;
 	}
 	error = vcc_connect(sock, addr->sap_addr.itf, addr->sap_addr.vpi,
 			    addr->sap_addr.vci);
@@ -51,11 +54,10 @@ out:
 	return error;
 }
 
-
-static int pvc_connect(struct socket *sock,struct sockaddr *sockaddr,
-    int sockaddr_len,int flags)
+static int pvc_connect(struct socket *sock, struct sockaddr *sockaddr,
+		       int sockaddr_len, int flags)
 {
-	return pvc_bind(sock,sockaddr,sockaddr_len);
+	return pvc_bind(sock, sockaddr, sockaddr_len);
 }
 
 static int pvc_setsockopt(struct socket *sock, int level, int optname,
@@ -70,7 +72,6 @@ static int pvc_setsockopt(struct socket *sock, int level, int optname,
 	return error;
 }
 
-
 static int pvc_getsockopt(struct socket *sock, int level, int optname,
 			  char __user *optval, int __user *optlen)
 {
@@ -83,16 +84,16 @@ static int pvc_getsockopt(struct socket *sock, int level, int optname,
 	return error;
 }
 
-
-static int pvc_getname(struct socket *sock,struct sockaddr *sockaddr,
-    int *sockaddr_len,int peer)
+static int pvc_getname(struct socket *sock, struct sockaddr *sockaddr,
+		       int *sockaddr_len, int peer)
 {
 	struct sockaddr_atmpvc *addr;
 	struct atm_vcc *vcc = ATM_SD(sock);
 
-	if (!vcc->dev || !test_bit(ATM_VF_ADDR,&vcc->flags)) return -ENOTCONN;
+	if (!vcc->dev || !test_bit(ATM_VF_ADDR, &vcc->flags))
+		return -ENOTCONN;
 	*sockaddr_len = sizeof(struct sockaddr_atmpvc);
-	addr = (struct sockaddr_atmpvc *) sockaddr;
+	addr = (struct sockaddr_atmpvc *)sockaddr;
 	addr->sap_family = AF_ATMPVC;
 	addr->sap_addr.itf = vcc->dev->number;
 	addr->sap_addr.vpi = vcc->vpi;
@@ -100,7 +101,6 @@ static int pvc_getname(struct socket *sock,struct sockaddr *sockaddr,
 	return 0;
 }
 
-
 static const struct proto_ops pvc_proto_ops = {
 	.family =	PF_ATMPVC,
 	.owner =	THIS_MODULE,
@@ -137,7 +137,6 @@ static int pvc_create(struct net *net, struct socket *sock, int protocol,
 	return vcc_create(net, sock, protocol, PF_ATMPVC);
 }
 
-
 static const struct net_proto_family pvc_family_ops = {
 	.family = PF_ATMPVC,
 	.create = pvc_create,
-- 
1.6.6.rc0.57.gad7a

