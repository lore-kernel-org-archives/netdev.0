From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netxen: netxen_rom_fast_read() doesn't return -1
Date: Thu, 5 May 2016 16:20:20 +0300
Message-ID: <20160505132019.GD3038@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The error handling is broken here.  netxen_rom_fast_read() returns zero
on success and -EIO on error.  It never returns -1.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index fd362b6..9c6eed9 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -852,7 +852,8 @@ netxen_check_options(struct netxen_adapter *adapter)
 	ptr32 = (__le32 *)&serial_num;
 	offset = NX_FW_SERIAL_NUM_OFFSET;
 	for (i = 0; i < 8; i++) {
-		if (netxen_rom_fast_read(adapter, offset, &val) == -1) {
+		err = netxen_rom_fast_read(adapter, offset, &val);
+		if (err) {
 			dev_err(&pdev->dev, "error reading board info\n");
 			adapter->driver_mismatch = 1;
 			return;
