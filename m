From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 7/9] sky2: synchronize irq on remove
Date: Mon, 08 May 2006 15:11:32 -0700
Message-ID: <20060508221229.408190000@localhost.localdomain>
References: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15805 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751330AbWEHWX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:59 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNmtH003757
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:50 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNmBE023566
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:48 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=sky2-sync-irq.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to make sure interrupt is not racing with unregister of
network device.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-05-02 09:49:47.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-02 10:02:32.000000000 -0700
@@ -3327,6 +3327,8 @@
 	del_timer_sync(&hw->idle_timer);
 
 	sky2_write32(hw, B0_IMSK, 0);
+	synchronize_irq(hw->pdev->irq);
+
 	dev0 = hw->dev[0];
 	dev1 = hw->dev[1];
 	if (dev1)

--

