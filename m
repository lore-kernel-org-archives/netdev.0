From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Possible bug with r8169 driver
Date: Mon, 1 Oct 2012 20:56:29 +0200
Message-ID: <20121001185629.GA4922@electric-eye.fr.zoreil.com>
References: <2197741.c8FeV4Xbis@bureau> <20120927222147.GA29047@electric-eye.fr.zoreil.com> <1478421.GOy9qdQlkG@bureau> <20120929072028.GA3730@electric-eye.fr.zoreil.com> <262549102A0343EDA34AA0A41217180C@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Nolwenn'" <donolwenn@gmail.com>, netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53273 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab2JATPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 15:15:54 -0400
Content-Disposition: inline
In-Reply-To: <262549102A0343EDA34AA0A41217180C@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> I need check it with our hardware engineers. I would reply after getting
> response.

Thanks.

> Could you try to set IO 0x08 ~ 0x0F to 0xff for testing, first?

Something like the patch below (against 3.5.4) ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index eb81da4..e0f1b8d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4271,8 +4271,8 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = swab32(data);
 	}
 
-	RTL_W32(MAR0 + 4, mc_filter[1]);
-	RTL_W32(MAR0 + 0, mc_filter[0]);
+	RTL_W32(MAR0 + 4, 0xffffffff);
+	RTL_W32(MAR0 + 0, 0xffffffff);
 
 	RTL_W32(RxConfig, tmp);
 }
