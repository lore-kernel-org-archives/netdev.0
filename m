From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 03/12] qlcnic: replace magic numbers with defines
Date: Thu, 19 Aug 2010 08:08:24 -0700
Message-ID: <1282230513-25286-4-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:4465 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753487Ab0HSPIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:34 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_hdr.h  |    4 ++++
 drivers/net/qlcnic/qlcnic_init.c |    4 ++--
 drivers/net/qlcnic/qlcnic_main.c |    2 +-
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 5c549c5..d198367 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -148,6 +148,7 @@
 
 #define DEFAULT_RCV_DESCRIPTORS_1G	2048
 #define DEFAULT_RCV_DESCRIPTORS_10G	4096
+#define MAX_RDS_RINGS                   2
 
 #define get_next_index(index, length)	\
 	(((index) + 1) & ((length) - 1))
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index bd346d9..39db4df 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -745,6 +745,10 @@ enum {
 #define FW_POLL_DELAY		(1 * HZ)
 #define FW_FAIL_THRESH		2
 
+#define QLCNIC_RESET_TIMEOUT_SECS	10
+#define QLCNIC_INIT_TIMEOUT_SECS	30
+
+
 #define	ISR_MSI_INT_TRIGGER(FUNC) (QLCNIC_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
 #define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
 
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 08da258..9076675 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -553,12 +553,12 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 	}
 	adapter->physical_port = (val >> 2);
 	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DEV_INIT_TIMEOUT, &timeo))
-		timeo = 30;
+		timeo = QLCNIC_INIT_TIMEOUT_SECS;
 
 	adapter->dev_init_timeo = timeo;
 
 	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DRV_RESET_TIMEOUT, &timeo))
-		timeo = 10;
+		timeo = QLCNIC_RESET_TIMEOUT_SECS;
 
 	adapter->reset_ack_timeo = timeo;
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index beadf2e..c6f19c9 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -754,7 +754,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	adapter->num_txd = MAX_CMD_DESCRIPTORS;
 
-	adapter->max_rds_rings = 2;
+	adapter->max_rds_rings = MAX_RDS_RINGS;
 }
 
 static int
-- 
1.6.0.2

