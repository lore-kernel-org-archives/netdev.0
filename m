From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/08: xt_socket: make module available for INPUT chain
Date: Thu,  3 Dec 2009 21:19:33 +0100 (MET)
Message-ID: <20091203201932.8831.58805.sendpatchset@x2.localnet>
References: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37692 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbZLCUT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:19:27 -0500
In-Reply-To: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit aa3c487f355ff1477b8369d9f0b9860387ae21d4
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Oct 29 15:35:10 2009 +0100

    netfilter: xt_socket: make module available for INPUT chain
    
    This should make it possible to test for the existence of local
    sockets in the INPUT path.
    
    References: http://marc.info/?l=netfilter-devel&m=125380481517129&w=2
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 362afbd..6a90256 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -192,7 +192,8 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 		.revision	= 0,
 		.family		= NFPROTO_IPV4,
 		.match		= socket_mt_v0,
-		.hooks		= 1 << NF_INET_PRE_ROUTING,
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
 		.me		= THIS_MODULE,
 	},
 	{
@@ -201,7 +202,8 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 		.family		= NFPROTO_IPV4,
 		.match		= socket_mt_v1,
 		.matchsize	= sizeof(struct xt_socket_mtinfo1),
-		.hooks		= 1 << NF_INET_PRE_ROUTING,
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
 		.me		= THIS_MODULE,
 	},
 };
