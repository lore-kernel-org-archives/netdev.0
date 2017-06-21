From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next 08/19] RDMA/core: Expose translation from device name to ib_device
Date: Wed, 21 Jun 2017 09:05:17 +0300
Message-ID: <20170621060528.3752-9-leon@kernel.org>
References: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57806 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751882AbdFUGGI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 02:06:08 -0400
In-Reply-To: <20170621060528.3752-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Provide ability to convert from device name to ib_device for the
IB/core users.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/core_priv.h | 1 +
 drivers/infiniband/core/device.c    | 3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/core_priv.h b/drivers/infiniband/core/core_priv.h
index 4a150c4be175..049ccbfca988 100644
--- a/drivers/infiniband/core/core_priv.h
+++ b/drivers/infiniband/core/core_priv.h
@@ -184,4 +184,5 @@ int ib_nl_handle_set_timeout(struct sk_buff *skb,
 int ib_nl_handle_ip_res_resp(struct sk_buff *skb,
 			     struct netlink_callback *cb);
 
+struct ib_device *__ib_device_get_by_name(const char *name);
 #endif /* _CORE_PRIV_H */
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 7a799fc90348..4ec1b24258de 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -124,7 +124,7 @@ static int ib_device_check_mandatory(struct ib_device *device)
 	return 0;
 }
 
-static struct ib_device *__ib_device_get_by_name(const char *name)
+struct ib_device *__ib_device_get_by_name(const char *name)
 {
 	struct ib_device *device;
 
@@ -135,7 +135,6 @@ static struct ib_device *__ib_device_get_by_name(const char *name)
 	return NULL;
 }
 
-
 static int alloc_name(char *name)
 {
 	unsigned long *inuse;
-- 
2.13.1
