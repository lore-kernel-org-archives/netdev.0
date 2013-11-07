From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net: make ndev->irq signed for error handling
Date: Thu, 7 Nov 2013 10:48:49 +0300
Message-ID: <20131107074849.GF21844@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38079 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291Ab3KGHs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:48:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a bug in cpsw_probe() where we do:

	ndev->irq = platform_get_irq(pdev, 0);
	if (ndev->irq < 0) {

The problem is that "ndev->irq" is unsigned so the error handling
doesn't work.  I have changed it to a regular int.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9da6a04..bb011f6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1132,7 +1132,7 @@ struct net_device {
 	unsigned long		mem_end;	/* shared mem end	*/
 	unsigned long		mem_start;	/* shared mem start	*/
 	unsigned long		base_addr;	/* device I/O address	*/
-	unsigned int		irq;		/* device IRQ number	*/
+	int			irq;		/* device IRQ number	*/
 
 	/*
 	 *	Some hardware also needs these fields, but they are not
