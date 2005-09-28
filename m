From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc2 1/2] s2io: change strncpy length arg to use size of target
Date: Wed, 28 Sep 2005 17:50:51 -0400
Message-ID: <09282005175051.10754@bilbo.tuxdriver.com>
References: <09282005175051.10698@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, leonid.grossman@neterion.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750930AbVI1Vx6@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09282005175051.10698@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the size of the target array for the length argument to strncpy
instead of the size of the source or a magic number.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/s2io.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3778,11 +3778,10 @@ static void s2io_ethtool_gdrvinfo(struct
 {
 	nic_t *sp = dev->priv;
 
-	strncpy(info->driver, s2io_driver_name, sizeof(s2io_driver_name));
-	strncpy(info->version, s2io_driver_version,
-		sizeof(s2io_driver_version));
-	strncpy(info->fw_version, "", 32);
-	strncpy(info->bus_info, pci_name(sp->pdev), 32);
+	strncpy(info->driver, s2io_driver_name, sizeof(info->driver));
+	strncpy(info->version, s2io_driver_version, sizeof(info->version));
+	strncpy(info->fw_version, "", sizeof(info->fw_version));
+	strncpy(info->bus_info, pci_name(sp->pdev), sizeof(info->bus_info));
 	info->regdump_len = XENA_REG_SPACE;
 	info->eedump_len = XENA_EEPROM_SPACE;
 	info->testinfo_len = S2IO_TEST_LEN;
