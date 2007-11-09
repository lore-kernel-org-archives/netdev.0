From: Urs Thuermann <urs.thuermann@gmx.de>
Subject: [PATCH] [AF_PACKET] Fix minor code duplication
Date: 09 Nov 2007 08:06:38 +0100
Message-ID: <ygfpryjaoe9.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:46012 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbXKIHKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 02:10:07 -0500
Received: from oker.escape.de (localhost [127.0.0.1])
	(envelope-sender: urs@isnogud.escape.de)
	by oker.escape.de (8.13.4/8.13.4/$Revision: 1.72 $) with ESMTP id lA97A5G5029032
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 9 Nov 2007 08:10:05 +0100
Received: (from uucp@localhost)
	by oker.escape.de (8.13.4/8.13.4/Submit) with UUCP id lA97A40O027820
	for netdev@vger.kernel.org; Fri, 9 Nov 2007 08:10:04 +0100
Received: from janus.isnogud.escape.de (localhost [127.0.0.1])
	by janus.isnogud.escape.de (8.13.8/8.13.8) with ESMTP id lA976dDp019798
	for <netdev@vger.kernel.org>; Fri, 9 Nov 2007 08:06:39 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify some code by eliminating duplicate if-else clauses in
packet_do_bind().


Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>


--- net-2.6/net/packet/af_packet.c.orig	2007-11-05 13:07:28.000000000 +0100
+++ net-2.6/net/packet/af_packet.c	2007-11-08 12:14:25.000000000 +0100
@@ -886,20 +886,14 @@ static int packet_do_bind(struct sock *s
 	if (protocol == 0)
 		goto out_unlock;
 
-	if (dev) {
-		if (dev->flags&IFF_UP) {
-			dev_add_pack(&po->prot_hook);
-			sock_hold(sk);
-			po->running = 1;
-		} else {
-			sk->sk_err = ENETDOWN;
-			if (!sock_flag(sk, SOCK_DEAD))
-				sk->sk_error_report(sk);
-		}
-	} else {
+	if (!dev || (dev->flags & IFF_UP)) {
 		dev_add_pack(&po->prot_hook);
 		sock_hold(sk);
 		po->running = 1;
+	} else {
+		sk->sk_err = ENETDOWN;
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_error_report(sk);
 	}
 
 out_unlock:
