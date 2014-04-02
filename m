From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: ti: fix CPTS driver build on arm
Date: Tue,  1 Apr 2014 18:26:48 -0700
Message-ID: <1396402008-3462-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:62617 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbaDBB0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 21:26:52 -0400
Received: by mail-pb0-f50.google.com with SMTP id md12so10770537pbc.9
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 18:26:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix build errors:
drivers/net/ethernet/ti/cpts.c:266:12: error: 'ETH_HLEN' undeclared (first use in this function)
drivers/net/ethernet/ti/cpts.c:276:23: error: 'VLAN_HLEN' undeclared (first use in this function)

Fixes: 408eccce3204 ("net: ptp: move PTP classifier in its own file")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Suggested-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>
---

arm build looks clean now.
Sorry for the prior breakage.

 drivers/net/ethernet/ti/cpts.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index a3bbf59eaafd..243513980b51 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -26,6 +26,8 @@
 #include <linux/time.h>
 #include <linux/uaccess.h>
 #include <linux/workqueue.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
 
 #include "cpts.h"
 
-- 
1.7.9.5
