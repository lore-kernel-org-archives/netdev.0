From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warnings after merge of the net tree
Date: Fri, 12 Aug 2011 03:01:36 -0700 (PDT)
Message-ID: <20110812.030136.187545256282831862.davem@davemloft.net>
References: <20110812115319.c48966a412362f68c00c19dc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110812115319.c48966a412362f68c00c19dc@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 12 Aug 2011 11:53:19 +1000

> warning: (SCSI_BNX2_ISCSI && SCSI_BNX2X_FCOE) selects CNIC which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_BROADCOM && PCI)
 ...
> warning: (SCSI_BNX2_ISCSI && SCSI_BNX2X_FCOE) selects CNIC which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_BROADCOM && PCI)

Ok, these were the only two problem areas left after the other
fixes posted today, fixed by the following patch.

Thanks!

--------------------
>From 4c78893b3d107e2a053c8f51c526510857c09858 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Fri, 12 Aug 2011 03:00:47 -0700
Subject: [PATCH] cnic: Fix select dependencies in bnx2fc/bnx2i Kconfig.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/scsi/bnx2fc/Kconfig |    3 ++-
 drivers/scsi/bnx2i/Kconfig  |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/bnx2fc/Kconfig b/drivers/scsi/bnx2fc/Kconfig
index 6a38080..cfcad8b 100644
--- a/drivers/scsi/bnx2fc/Kconfig
+++ b/drivers/scsi/bnx2fc/Kconfig
@@ -2,7 +2,8 @@ config SCSI_BNX2X_FCOE
 	tristate "Broadcom NetXtreme II FCoE support"
 	depends on PCI
 	select NETDEVICES
-	select NETDEV_1000
+	select ETHERNET
+	select NET_VENDOR_BROADCOM
 	select LIBFC
 	select LIBFCOE
 	select CNIC
diff --git a/drivers/scsi/bnx2i/Kconfig b/drivers/scsi/bnx2i/Kconfig
index 45a6154..01cff18 100644
--- a/drivers/scsi/bnx2i/Kconfig
+++ b/drivers/scsi/bnx2i/Kconfig
@@ -4,7 +4,8 @@ config SCSI_BNX2_ISCSI
 	depends on PCI
 	select SCSI_ISCSI_ATTRS
 	select NETDEVICES
-	select NETDEV_1000
+	select ETHERNET
+	select NET_VENDOR_BROADCOM
 	select CNIC
 	---help---
 	This driver supports iSCSI offload for the Broadcom NetXtreme II
-- 
1.7.6
