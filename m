From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 06/11] net: ehea: convert to use DRIVER_ATTR_RO
Date: Fri,  9 Jun 2017 11:03:09 +0200
Message-ID: <20170609090314.13991-6-gregkh@linuxfoundation.org>
References: <20170609090314.13991-1-gregkh@linuxfoundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Douglas Miller <dougmill@linux.vnet.ibm.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170609090314.13991-1-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We are trying to get rid of DRIVER_ATTR(), and the ehea driver's
attribute can be trivially changed to use DRIVER_ATTR_RO().

Cc: Douglas Miller <dougmill@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 1e53d7a82675..b9d310f20bcc 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3553,14 +3553,12 @@ static int check_module_parm(void)
 	return ret;
 }
 
-static ssize_t ehea_show_capabilities(struct device_driver *drv,
-				      char *buf)
+static ssize_t capabilities_show(struct device_driver *drv, char *buf)
 {
 	return sprintf(buf, "%d", EHEA_CAPABILITIES);
 }
 
-static DRIVER_ATTR(capabilities, S_IRUSR | S_IRGRP | S_IROTH,
-		   ehea_show_capabilities, NULL);
+static DRIVER_ATTR_RO(capabilities);
 
 static int __init ehea_module_init(void)
 {
-- 
2.13.1
