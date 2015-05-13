From: sfeldma@gmail.com
Subject: [PATCH net-next 2/4] switchdev: sparse warning: pass ipv4 fib dst as network-byte order
Date: Tue, 12 May 2015 23:03:52 -0700
Message-ID: <1431497034-22153-3-git-send-email-sfeldma@gmail.com>
References: <1431497034-22153-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33121 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbbEMGCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:02:52 -0400
Received: by pdbnk13 with SMTP id nk13so40685126pdb.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 23:02:52 -0700 (PDT)
In-Reply-To: <1431497034-22153-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

And let driver convert it to host-byte order as needed.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    7 ++++---
 net/switchdev/switchdev.c            |    4 ++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 1fc006b..ca53393 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4471,7 +4471,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->ipv4_fib;
 		err = rocker_port_fib_ipv4(rocker_port, obj->trans,
-					   fib4->dst, fib4->dst_len,
+					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
 	default:
@@ -4525,8 +4525,9 @@ static int rocker_port_obj_del(struct net_device *dev,
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->ipv4_fib;
 		err = rocker_port_fib_ipv4(rocker_port, SWITCHDEV_TRANS_NONE,
-					   fib4->dst, fib4->dst_len, fib4->fi,
-					   fib4->tb_id, ROCKER_OP_FLAG_REMOVE);
+					   htonl(fib4->dst), fib4->dst_len,
+					   fib4->fi, fib4->tb_id,
+					   ROCKER_OP_FLAG_REMOVE);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index a267f77..77f1b6e 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -645,7 +645,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	struct switchdev_obj fib_obj = {
 		.id = SWITCHDEV_OBJ_IPV4_FIB,
 		.ipv4_fib = {
-			.dst = htonl(dst),
+			.dst = dst,
 			.dst_len = dst_len,
 			.fi = fi,
 			.tos = tos,
@@ -699,7 +699,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	struct switchdev_obj fib_obj = {
 		.id = SWITCHDEV_OBJ_IPV4_FIB,
 		.ipv4_fib = {
-			.dst = htonl(dst),
+			.dst = dst,
 			.dst_len = dst_len,
 			.fi = fi,
 			.tos = tos,
-- 
1.7.10.4
