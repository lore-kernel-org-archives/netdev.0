From: <gregkh@linuxfoundation.org>
Subject: patch "net: ehea: convert to use DRIVER_ATTR_RO" added to driver-core-testing
Date: Mon, 12 Jun 2017 16:15:25 +0200
Message-ID: <149727692587250@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
To: gregkh@linuxfoundation.org, davem@davemloft.net,
        dougmill@linux.vnet.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:56790 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752564AbdFLOPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 10:15:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    net: ehea: convert to use DRIVER_ATTR_RO

to my driver-core git tree which can be found at
    git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core.git
in the driver-core-testing branch.

The patch will show up in the next release of the linux-next tree
(usually sometime within the next 24 hours during the week.)

The patch will be merged to the driver-core-next branch sometime soon,
after it passes testing, and the merge window is open.

If you have any questions about this process, please let me know.


>From ce8e0cd892c66be110613876dded547acc66da13 Mon Sep 17 00:00:00 2001
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 9 Jun 2017 11:03:09 +0200
Subject: net: ehea: convert to use DRIVER_ATTR_RO

We are trying to get rid of DRIVER_ATTR(), and the ehea driver's
attribute can be trivially changed to use DRIVER_ATTR_RO().

Cc: Douglas Miller <dougmill@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>
Acked-by: David S. Miller <davem@davemloft.net>
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
