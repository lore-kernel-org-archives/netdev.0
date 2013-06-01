From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: ethernet: replace strict_strtoul() with kstrtoul()
Date: Sat, 01 Jun 2013 16:21:35 +0900
Message-ID: <000e01ce5e98$a65d5ee0$f3181ca0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Manish Chopra' <manish.chopra@qlogic.com>,
	'Sony Chacko' <sony.chacko@qlogic.com>,
	'Rajesh Borundia' <rajesh.borundia@qlogic.com>,
	'Shahed Shaikh' <shahed.shaikh@qlogic.com>,
	'Jitendra Kalsaria' <jitendra.kalsaria@qlogic.com>,
	linux-driver@qlogic.com
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:13277 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab3FAHVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 03:21:37 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MNP0022ODRZBUE0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Sat, 01 Jun 2013 16:21:36 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The usage of strict_strtoul() is not preferred, because
strict_strtoul() is obsolete. Thus, kstrtoul() should be
used.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c    |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 51e13d9..7fdf6b2 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2721,7 +2721,7 @@ netxen_store_bridged_mode(struct device *dev,
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
 		goto err_out;
 
-	if (strict_strtoul(buf, 2, &new))
+	if (kstrtoul(buf, 2, &new))
 		goto err_out;
 
 	if (!netxen_config_bridged_mode(adapter, !!new))
@@ -2760,7 +2760,7 @@ netxen_store_diag_mode(struct device *dev,
 	struct netxen_adapter *adapter = dev_get_drvdata(dev);
 	unsigned long new;
 
-	if (strict_strtoul(buf, 2, &new))
+	if (kstrtoul(buf, 2, &new))
 		return -EINVAL;
 
 	if (!!new != !!(adapter->flags & NETXEN_NIC_DIAG_ENABLED))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 025a719..7ec030a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -47,7 +47,7 @@ static ssize_t qlcnic_store_bridged_mode(struct device *dev,
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		goto err_out;
 
-	if (strict_strtoul(buf, 2, &new))
+	if (kstrtoul(buf, 2, &new))
 		goto err_out;
 
 	if (!qlcnic_config_bridged_mode(adapter, !!new))
@@ -77,7 +77,7 @@ static ssize_t qlcnic_store_diag_mode(struct device *dev,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	unsigned long new;
 
-	if (strict_strtoul(buf, 2, &new))
+	if (kstrtoul(buf, 2, &new))
 		return -EINVAL;
 
 	if (!!new != !!(adapter->flags & QLCNIC_DIAG_ENABLED))
-- 
1.7.10.4
