From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH net-next 2/2] add one config to select relax order mode in intel NIC's Kconfig
Date: Fri, 3 Feb 2017 17:30:33 +0800
Message-ID: <1486114233-9800-3-git-send-email-maowenan@huawei.com>
References: <1486114233-9800-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <alexander.duyck@gmail.com>,
        <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:1509 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752908AbdBCJby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:31:54 -0500
In-Reply-To: <1486114233-9800-1-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows one to enable relax order mode in intel NIC's
Kconfig. CONFIG_ARCH_WANT_RELAX_ORDER is a common macro for some
CPU architecture to use relax order mode in NIC's source codes.
CONFIG_ARCH_WANT_RELAX_ORDER can be defined in arch/xxx/Kconfig,
such as sparc system exists in arch/sparc/Kconfig, but not all
of arm64 systems can use relax order mode, so it can't be defined
in arch/arm64/Kconfig. Therefore PCI_RELAX_ORDER in NIC's Kconfig
provide one way to define macro CONFIG_ARCH_WANT_RELAX_ORDER.

Signed-off-by: Mao Wenan <maowenan@huawei.com>
---
 drivers/net/ethernet/intel/Kconfig | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 1349b45..b366722 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -275,4 +275,19 @@ config FM10K
 	  To compile this driver as a module, choose M here. The module
 	  will be called fm10k.  MSI-X interrupt support is required
 
+config PCI_RELAX_ORDER
+        bool "PCI relax order mode support"
+        default n
+        select ARCH_WANT_RELAX_ORDER
+        ---help---
+          This allows one to enable relax order mode in driver.
+          CONFIG_ARCH_WANT_RELAX_ORDER is a common macro for some
+          CPU architecture to use relax order mode in NIC's source codes.
+          CONFIG_ARCH_WANT_RELAX_ORDER can be defined in arch/xxx/Kconfig,
+          such as sparc system exists in arch/sparc/Kconfig, but not all
+          of arm64 systems can use relax order mode, so it can't be defined
+          in arch/arm64/Kconfig. Therefore PCI_RELAX_ORDER provide one way
+          to define macro CONFIG_ARCH_WANT_RELAX_ORDER. Say Y here if you
+          want to enable relax order.
+
 endif # NET_VENDOR_INTEL
-- 
2.7.0
