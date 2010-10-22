From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 3/3] vmxnet3: fix typo setting confPA
Date: Thu, 21 Oct 2010 21:05:34 -0700
Message-ID: <1287720334-15469-3-git-send-email-harvey.harrison@gmail.com>
References: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:33008 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab0JVEFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 00:05:42 -0400
Received: by mail-px0-f174.google.com with SMTP id 12so63626pxi.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 21:05:42 -0700 (PDT)
In-Reply-To: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a le64, not a le32, typo in one place only.

Noticed by sparse:
drivers/net/vmxnet3/vmxnet3_drv.c:2668:52: warning: incorrect type in assignment (different base types)
drivers/net/vmxnet3/vmxnet3_drv.c:2668:52:    expected restricted __le64 [usertype] confPA
drivers/net/vmxnet3/vmxnet3_drv.c:2668:52:    got restricted __le32 [usertype] <noident>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 2ea4b81..e3658e1 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2665,7 +2665,7 @@ vmxnet3_resume(struct device *device)
 	adapter->shared->devRead.pmConfDesc.confVer = cpu_to_le32(1);
 	adapter->shared->devRead.pmConfDesc.confLen = cpu_to_le32(sizeof(
 								  *pmConf));
-	adapter->shared->devRead.pmConfDesc.confPA = cpu_to_le32(virt_to_phys(
+	adapter->shared->devRead.pmConfDesc.confPA = cpu_to_le64(virt_to_phys(
 								 pmConf));
 
 	netif_device_attach(netdev);
-- 
1.7.1

