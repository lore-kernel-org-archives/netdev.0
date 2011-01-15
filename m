From: Shreyas N Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next 2/8] vmxnet3: Preserve the MAC address configured by
	ifconfig
Date: Fri, 14 Jan 2011 16:59:31 -0800
Message-ID: <20110115005930.1064.82144.stgit@sbhatewara-dev1.eng.vmware.com>
References: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:4714 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752160Ab1AOA73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 19:59:29 -0500
In-Reply-To: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While activating the device get it's MAC address from netdev. This will allow
the MAC address iconfigured using ifconfig to persist through the reset.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 562bdbb..89bcee8 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -48,6 +48,9 @@ static atomic_t devices_found;
 static int enable_mq = 1;
 static int irq_share_mode;
 
+static void
+vmxnet3_write_mac_addr(struct vmxnet3_adapter *adapter, u8 *mac);
+
 /*
  *    Enable/Disable the given intr
  */
@@ -2168,6 +2171,8 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 	/* rx filter settings */
 	devRead->rxFilterConf.rxMode = 0;
 	vmxnet3_restore_vlan(adapter);
+	vmxnet3_write_mac_addr(adapter, adapter->netdev->dev_addr);
+
 	/* the rest are already zeroed */
 }
 

