From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] at1700: Read buffer overflow
Date: Sun, 26 Jul 2009 00:01:50 +0200
Message-ID: <4A6B80CE.6060702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:31520 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbZGYV7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 17:59:16 -0400
Received: by ey-out-2122.google.com with SMTP id 9so639447eyd.37
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 14:59:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

loop bound looks to be wrong, for an array of length 8

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Or is a value is missing? (others contrastingly end with `, 0')

diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 18b566a..cf30e27 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -318,7 +318,7 @@ static int __init at1700_probe1(struct net_device *dev, int ioaddr)
 				pos3 = mca_read_stored_pos( slot, 3 );
 				pos4 = mca_read_stored_pos( slot, 4 );
 
-				for (l_i = 0; l_i < 0x09; l_i++)
+				for (l_i = 0; l_i < 8; l_i++)
 					if (( pos3 & 0x07) == at1700_ioaddr_pattern[l_i])
 						break;
 				ioaddr = at1700_mca_probe_list[l_i];
