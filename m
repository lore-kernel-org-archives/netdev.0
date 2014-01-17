From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 8/9] i40e: add DCB option to Kconfig
Date: Fri, 17 Jan 2014 15:36:38 -0800
Message-ID: <1390001799-19425-9-git-send-email-aaron.f.brown@intel.com>
References: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Cc: Neerav Parikh <Neerav.Parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55373 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753115AbaAQXhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 18:37:02 -0500
In-Reply-To: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <Neerav.Parikh@intel.com>

Allow compiling DCB related files if I40E_DCB option
is supported in the kernel configuration.

DCB is disabled by default.

Signed-off-by: Neerav Parikh <Neerav.Parikh@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Tested-By: Jack Morgan<jack.morgan@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/Kconfig       | 8 ++++++++
 drivers/net/ethernet/intel/i40e/Makefile | 2 ++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 333bb54..bb9f0ba 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -271,6 +271,14 @@ config I40E_VXLAN
 	  Say Y here if you want to use Virtual eXtensible Local Area Network
 	  (VXLAN) in the driver.
 
+config I40E_DCB
+	bool "Data Center Bridging (DCB) Support"
+	default n
+	depends on I40E && DCB
+	---help---
+	  Say Y here if you want to use Data Center Bridging (DCB) in the
+	  driver.
+
 	  If unsure, say N.
 
 config I40EVF
diff --git a/drivers/net/ethernet/intel/i40e/Makefile b/drivers/net/ethernet/intel/i40e/Makefile
index e4d2e27..d9eb80a 100644
--- a/drivers/net/ethernet/intel/i40e/Makefile
+++ b/drivers/net/ethernet/intel/i40e/Makefile
@@ -42,3 +42,5 @@ i40e-objs := i40e_main.o \
 	i40e_txrx.o	\
 	i40e_ptp.o	\
 	i40e_virtchnl_pf.o
+
+i40e-$(CONFIG_I40E_DCB) += i40e_dcb.o i40e_dcb_nl.o
-- 
1.8.5.GIT
