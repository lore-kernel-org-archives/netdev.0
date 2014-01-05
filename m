From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: Dump the whole NVM, not half
Date: Sun,  5 Jan 2014 02:46:53 -0800
Message-ID: <1388918827-13430-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21383 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093AbaAEKrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:11 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Debugfs was reading exactly half the number of words, fix it.

Change-Id: Ieb217f3c6dca455d44e50a0dc61a6664c0cb2265
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index df569fd..934623e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -65,7 +65,7 @@
 #define I40E_MAX_NPAR_QPS     32
 
 #define I40E_MAX_NUM_DESCRIPTORS      4096
-#define I40E_MAX_REGISTER     0x0038FFFF
+#define I40E_MAX_REGISTER     0x800000
 #define I40E_DEFAULT_NUM_DESCRIPTORS  512
 #define I40E_REQ_DESCRIPTOR_MULTIPLE  32
 #define I40E_MIN_NUM_DESCRIPTORS      64
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index e201060..7f448b6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1740,10 +1740,10 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			dev_info(&pf->pdev->dev,
 				 "Read NVM module=0x%x offset=0x%x words=%d\n",
 				 module, offset, buffer_len);
-			if (buffer_len)
+			if (bytes)
 				print_hex_dump(KERN_INFO, "NVM Dump: ",
 					DUMP_PREFIX_OFFSET, 16, 2,
-					buff, buffer_len, true);
+					buff, bytes, true);
 		}
 		kfree(buff);
 		buff = NULL;
-- 
1.8.3.1
