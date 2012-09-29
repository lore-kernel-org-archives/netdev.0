From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Possible bug with r8169 driver
Date: Sat, 29 Sep 2012 21:01:05 +0200
Message-ID: <20120929190105.GA8903@electric-eye.fr.zoreil.com>
References: <2197741.c8FeV4Xbis@bureau> <1478421.GOy9qdQlkG@bureau> <20120929072028.GA3730@electric-eye.fr.zoreil.com> <2565578.vyFL3Bzlf9@bureau>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Nolwenn <donolwenn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50376 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757344Ab2I2TUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2012 15:20:14 -0400
Content-Disposition: inline
In-Reply-To: <2565578.vyFL3Bzlf9@bureau>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nolwenn <donolwenn@gmail.com> :
[...]
> The two dumps are attached (I hope it's what Michel wants !)

(Michel ?)

The device does not see the multicast router advertisement.

Please try the hack below.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b47d5b3..8080dac 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4522,6 +4522,8 @@ static void rtl_set_rx_mode(struct net_device *dev)
 
 		mc_filter[0] = swab32(mc_filter[1]);
 		mc_filter[1] = swab32(data);
+		tmp |= 0xff7e1880;
+		RTL_W32(RxConfig, tmp);
 	}
 
 	RTL_W32(MAR0 + 4, mc_filter[1]);
