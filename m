From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 14:18:14 -0700
Message-ID: <20130723141814.4d5ad51f@nehalam.linuxnetplumber.net>
References: <4961229.bXDGvH0dpz@al>
	<20130723085436.70e8588c@nehalam.linuxnetplumber.net>
	<2856794.AWy189S2qk@al>
	<20130723091722.1e791f0c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Wu <lekensteyn@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:47185 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932567Ab3GWVSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 17:18:17 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so69963pab.1
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 14:18:17 -0700 (PDT)
In-Reply-To: <20130723091722.1e791f0c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is what I was talking about, some patch like this.


--- a/drivers/net/ethernet/realtek/r8169.c	2013-07-19 09:12:37.121530393 -0700
+++ b/drivers/net/ethernet/realtek/r8169.c	2013-07-23 14:16:20.239516611 -0700
@@ -1496,11 +1496,12 @@ static void __rtl8169_check_link_status(
 		if (pm)
 			pm_request_resume(&tp->pci_dev->dev);
 		netif_carrier_on(dev);
-		if (net_ratelimit())
+		if (netif_msg_ifup(tp))
 			netif_info(tp, ifup, dev, "link up\n");
 	} else {
 		netif_carrier_off(dev);
-		netif_info(tp, ifdown, dev, "link down\n");
+		if (netif_msg_ifdown(tp))
+			netif_info(tp, ifdown, dev, "link down\n");
 		if (pm)
 			pm_schedule_suspend(&tp->pci_dev->dev, 5000);
 	}
