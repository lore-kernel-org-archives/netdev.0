From: Leon Romanovsky <leonro@mellanox.com>
Subject: [PATCH REPOST v5 iproute2 1/8] utils: Move BIT macro to common header
Date: Thu, 17 Aug 2017 09:56:07 +0300
Message-ID: <20170817065614.1393-2-leonro@mellanox.com>
References: <20170817065614.1393-1-leonro@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        David Laight <David.Laight@ACULAB.COM>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57198 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751781AbdHQG4V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 02:56:21 -0400
In-Reply-To: <20170817065614.1393-1-leonro@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BIT() macro was implemented and used by devlink for now, but following
patches of rdmatool will reuse the same macro, so put it in common
header file.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 devlink/devlink.c | 2 +-
 include/utils.h   | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index f9bc16c3..7602970b 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -25,6 +25,7 @@
 #include "list.h"
 #include "mnlg.h"
 #include "json_writer.h"
+#include "utils.h"

 #define ESWITCH_MODE_LEGACY "legacy"
 #define ESWITCH_MODE_SWITCHDEV "switchdev"
@@ -160,7 +161,6 @@ static void ifname_map_free(struct ifname_map *ifname_map)
 	free(ifname_map);
 }

-#define BIT(nr)                 (1UL << (nr))
 #define DL_OPT_HANDLE		BIT(0)
 #define DL_OPT_HANDLEP		BIT(1)
 #define DL_OPT_PORT_TYPE	BIT(2)
diff --git a/include/utils.h b/include/utils.h
index 6080b962..7a3b3fd2 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -195,6 +195,8 @@ static inline void __jiffies_to_tv(struct timeval *tv, unsigned long jiffies)
 int print_timestamp(FILE *fp);
 void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n);

+#define BIT(nr)                 (1UL << (nr))
+
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

 #define BUILD_BUG_ON(cond) ((void)sizeof(char[1 - 2 * !!(cond)]))
