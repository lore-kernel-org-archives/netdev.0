From: Ken Kawasaki <ken_kawasaki@nifty.com>
Subject: [PATCH] fmvj18x_cs: The MAC address of FMV-J182 is stored at buf[5]
Date: Sat, 20 Feb 2016 10:57:06 +0900
Message-ID: <20160220105706.c4da2bbf13902b8bb4df3808@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from conuserg010.nifty.com ([202.248.44.36]:51906 "EHLO
	conuserg010-v.nifty.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965103AbcBTB5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 20:57:22 -0500
Received: from localhost.localdomain (49.253.220.168.eo.eaccess.ne.jp [49.253.220.168]) (authenticated)
	by conuserg010-v.nifty.com with ESMTP id u1K1v6BE022461
	for <netdev@vger.kernel.org>; Sat, 20 Feb 2016 10:57:07 +0900
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The MAC address of FMV-J182 is stored at buf[5].

Signed-off-by: Ken Kawasaki <ken_kawasaki@nifty.com>

---

--- linux-4.4.1/drivers/net/ethernet/fujitsu/fmvj18x_cs.c.orig	2016-02-19 20:48:40.143852346 +0900
+++ linux-4.4.1/drivers/net/ethernet/fujitsu/fmvj18x_cs.c	2016-02-20 10:33:42.137713831 +0900
@@ -469,8 +469,8 @@ static int fmvj18x_config(struct pcmcia_
 		    goto failed;
 	    }
 	    /* Read MACID from CIS */
-	    for (i = 5; i < 11; i++)
-		    dev->dev_addr[i] = buf[i];
+	    for (i = 0; i < 6; i++)
+		    dev->dev_addr[i] = buf[i + 5];
 	    kfree(buf);
 	} else {
 	    if (pcmcia_get_mac_from_cis(link, dev))
