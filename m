From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 2/4] cxgb4i: don't redefine DIV_ROUND_UP
Date: Fri,  4 Mar 2016 11:52:17 +0100
Message-ID: <1457088739-1065-3-git-send-email-nicolas.dichtel@6wind.com>
References: <20160303.170804.2300821465150459193.davem@davemloft.net>
 <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, ben@decadent.org.uk,
	Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:49066 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbcCDKws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 05:52:48 -0500
In-Reply-To: <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

let's use the common definition to avoid the following warning during the
compilation:

drivers/scsi/cxgbi/cxgb4i/cxgb4i.c:161:0: warning: "DIV_ROUND_UP" redefined
 #define DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
 ^
In file included from include/linux/list.h:8:0,
                 from include/linux/module.h:9,
                 from drivers/scsi/cxgbi/cxgb4i/cxgb4i.c:16:
include/linux/kernel.h:67:0: note: this is the location of the previous definition
 #define DIV_ROUND_UP __KERNEL_DIV_ROUND_UP
 ^

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 804806e1cbb4..339f6b7f4803 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -13,6 +13,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
 
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <scsi/scsi_host.h>
@@ -158,7 +159,6 @@ static struct scsi_transport_template *cxgb4i_stt;
  * open/close/abort and data send/receive.
  */
 
-#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
 #define RCV_BUFSIZ_MASK		0x3FFU
 #define MAX_IMM_TX_PKT_LEN	256
 
-- 
2.4.2
