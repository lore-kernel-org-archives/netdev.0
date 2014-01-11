From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 17/17] i40evf: fix s390 build failure due to implicit prefetch.h
Date: Fri, 10 Jan 2014 16:47:30 -0800
Message-ID: <1389401250-11509-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2329 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752851AbaAKArx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 19:47:53 -0500
In-Reply-To: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>

As of commit 7f12ad741a4870b8b6e3aafbcd868d0191770802 ("i40evf: transmit
and receive functionality") the s390 builds (allyesconfig) fail with:

drivers/net/ethernet/intel/i40evf/i40e_txrx.c: In function 'i40e_clean_rx_irq':
drivers/net/ethernet/intel/i40evf/i40e_txrx.c:818:3: error: implicit declaration of function 'prefetch'
make[5]: *** [drivers/net/ethernet/intel/i40evf/i40e_txrx.o] Error 1

due to an implicit assumption that the prototype from linux/prefetch.h
will be present.

Cc: Mitch Williams <mitch.a.williams@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 8f2b3b2..ffdb01d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -21,6 +21,8 @@
  *
  ******************************************************************************/
 
+#include <linux/prefetch.h>
+
 #include "i40evf.h"
 
 static inline __le64 build_ctob(u32 td_cmd, u32 td_offset, unsigned int size,
-- 
1.8.3.1
