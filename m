From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] yam: integer underflow in yam_ioctl()
Date: Mon, 14 Oct 2013 15:28:38 +0300
Message-ID: <20131014121931.GI6247@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jean-Paul Roubelat <jpr@f6fbb.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We cap bitrate at YAM_MAXBITRATE in yam_ioctl(), but it could also be
negative.  I don't know the impact of using a negative bitrate but let's
prevent it.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/include/linux/yam.h b/include/linux/yam.h
index 7fe2822..512cdc2 100644
--- a/include/linux/yam.h
+++ b/include/linux/yam.h
@@ -77,6 +77,6 @@ struct yamdrv_ioctl_cfg {
 
 struct yamdrv_ioctl_mcs {
 	int cmd;
-	int bitrate;
+	unsigned int bitrate;
 	unsigned char bits[YAM_FPGA_SIZE];
 };
