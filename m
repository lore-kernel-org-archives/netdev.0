From: Andy Whitcroft <apw@canonical.com>
Subject: [PATCH 1/1] xen-netback: include definition of csum_ipv6_magic
Date: Mon, 25 Nov 2013 16:52:34 +0000
Message-ID: <1385398354-21636-1-git-send-email-apw@canonical.com>
Cc: Andy Whitcroft <apw@canonical.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We are now using csum_ipv6_magic, include the appropriate header.
Avoids the following error:

    drivers/net/xen-netback/netback.c:1313:4: error: implicit declaration of function 'csum_ipv6_magic' [-Werror=implicit-function-declaration]
        tcph->check = ~csum_ipv6_magic(&ipv6h->saddr,

Signed-off-by: Andy Whitcroft <apw@canonical.com>
---
 drivers/net/xen-netback/netback.c | 1 +
 1 file changed, 1 insertion(+)

    Found while trying to couple latest kernels for arm64 platforms.
    Looks like it got missed in the transition.

    -apw

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 919b650..64f0e0d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -39,6 +39,7 @@
 #include <linux/udp.h>
 
 #include <net/tcp.h>
+#include <net/ip6_checksum.h>
 
 #include <xen/xen.h>
 #include <xen/events.h>
-- 
1.8.3.2
