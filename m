From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 3/6] qlcnic: Use usleep_range() instead of msleep() for sleep less than 20ms
Date: Wed, 27 Aug 2014 12:43:19 -0400
Message-ID: <1409157802-7895-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1409157802-7895-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:15322 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935251AbaH0RQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 13:16:38 -0400
In-Reply-To: <1409157802-7895-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

As per recommendation, msleep() may sleep longer than intended time for
values less than 20ms. So, use usleep_range() instead of msleep()

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c      | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c    | 6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 528c651..840bf36 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2701,7 +2701,7 @@ static int qlcnic_83xx_poll_flash_status_reg(struct qlcnic_adapter *adapter)
 		    QLC_83XX_FLASH_STATUS_READY)
 			break;
 
-		msleep(QLC_83XX_FLASH_STATUS_REG_POLL_DELAY);
+		usleep_range(1000, 1100);
 	} while (--retries);
 
 	if (!retries)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 851cb4a..8102673 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -341,7 +341,7 @@ qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 			}
 			return -EIO;
 		}
-		msleep(1);
+		usleep_range(1000, 1500);
 	}
 
 	if (id_reg)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index c4262c2..be41e4c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -537,7 +537,7 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0xc, 0);
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x8, 0);
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0xc, 0);
-	msleep(1);
+	usleep_range(1000, 1500);
 
 	QLC_SHARED_REG_WR32(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
 	QLC_SHARED_REG_WR32(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
@@ -1198,7 +1198,7 @@ qlcnic_load_firmware(struct qlcnic_adapter *adapter)
 			flashaddr += 8;
 		}
 	}
-	msleep(1);
+	usleep_range(1000, 1500);
 
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x18, 0x1020);
 	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0x80001e);
@@ -1295,7 +1295,7 @@ next:
 		rc = qlcnic_validate_firmware(adapter);
 		if (rc != 0) {
 			release_firmware(adapter->fw);
-			msleep(1);
+			usleep_range(1000, 1500);
 			goto next;
 		}
 	}
-- 
1.8.1.4
