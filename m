From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 01/12] fib: notifier: Add VIF add and delete event types
Date: Wed, 27 Sep 2017 08:23:11 +0200
Message-ID: <20170927062322.5476-2-jiri@resnulli.us>
References: <20170927062322.5476-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        linyunsheng@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33570 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdI0GXZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 02:23:25 -0400
Received: by mail-wr0-f196.google.com with SMTP id b9so3594100wra.0
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 23:23:25 -0700 (PDT)
In-Reply-To: <20170927062322.5476-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

In order for an interface to forward packets according to the kernel
multicast routing table, it must be configured with a VIF index according
to the mroute user API. The VIF index is then used to refer to that
interface in the mroute user API, for example, to set the iif and oifs of
an MFC entry.

In order to allow drivers to be aware and offload multicast routes, they
have to be aware of the VIF add and delete notifications.

Due to the fact that a specific VIF can be deleted and re-added pointing to
another netdevice, and the MFC routes that point to it will forward the
matching packets to the new netdevice, a driver willing to offload MFC
cache entries must be aware of the VIF add and delete events in addition to
MFC routes notifications.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/net/fib_notifier.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/fib_notifier.h b/include/net/fib_notifier.h
index 669b971..54cd6b8 100644
--- a/include/net/fib_notifier.h
+++ b/include/net/fib_notifier.h
@@ -20,6 +20,8 @@ enum fib_event_type {
 	FIB_EVENT_RULE_DEL,
 	FIB_EVENT_NH_ADD,
 	FIB_EVENT_NH_DEL,
+	FIB_EVENT_VIF_ADD,
+	FIB_EVENT_VIF_DEL,
 };
 
 struct fib_notifier_ops {
-- 
2.9.5
