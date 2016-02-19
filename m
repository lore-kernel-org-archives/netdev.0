From: Ken Kawasaki <ken_kawasaki@nifty.com>
Subject: [PATCH]fmvj18x_cs: The MAC address of FMV-J182 is stored at buf[5].
Date: Fri, 19 Feb 2016 21:38:35 +0900
Message-ID: <20160219213835.c16a60105e0342ff64b7b8aa@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from conuserg010.nifty.com ([202.248.44.36]:27059 "EHLO
	conuserg010-v.nifty.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757578AbcBSMix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 07:38:53 -0500
Received: from localhost.localdomain (49.253.220.168.eo.eaccess.ne.jp [49.253.220.168]) (authenticated)
	by conuserg010-v.nifty.com with ESMTP id u1JCcanY015380
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 21:38:36 +0900
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The MAC address of FMV-J182 is stored at buf[5].

Signed-off-by: Ken Kawasaki <ken_kawasaki@nifty.com>

---

--- linux-4.4.1/drivers/net/ethernet/fujitsu/fmvj18x_cs.c.orig	2016-02-19 20:48:40.143852346 +0900
+++ linux-4.4.1/drivers/net/ethernet/fujitsu/fmvj18x_cs.c	2016-02-19 20:54:52.345568822 +0900
@@ -469,8 +469,8 @@ static int fmvj18x_config(struct pcmcia_
 		    goto failed;
 	    }
 	    /* Read MACID from CIS */
-	    for (i = 5; i < 11; i++)
-		    dev->dev_addr[i] = buf[i];
+	    for (i = 0; i < 6; i++)
+		    dev->dev_addr[i] = buf[i+5];
 	    kfree(buf);
 	} else {
 	    if (pcmcia_get_mac_from_cis(link, dev))
