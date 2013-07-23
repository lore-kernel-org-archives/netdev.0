From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH v2] r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 14:38:46 +0200
Message-ID: <1765554.SGJMeyexPP@al>
References: <4961229.bXDGvH0dpz@al> <51EE75A1.3070804@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:46069 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab3GWMiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 08:38:51 -0400
Received: by mail-ee0-f43.google.com with SMTP id l10so4446394eei.2
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 05:38:50 -0700 (PDT)
In-Reply-To: <51EE75A1.3070804@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message was added in commit a7154cb8 (June 2004, [PATCH] r8169:
link handling and phy reset rework) and is printed every ten seconds
when no cable is connected. (Before that commit, "Reset RTL8169s PHY"
would be printed instead.)

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---

On Tuesday 23 July 2013 16:22:57 Sergei Shtylyov wrote:
> On 23-07-2013 13:55, Peter Wu wrote:
> > This message was added in commit a7154cb8 (June 2004) and is printed
> 
>     Please also specify that commit's summary line in parens.
Done, while at it I have also noted that an other spam message would be
logged.
---
 drivers/net/ethernet/realtek/r8169.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 880015c..63f04af 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3689,8 +3689,6 @@ static void rtl_phy_work(struct rtl8169_private *tp)
 	if (tp->link_ok(ioaddr))
 		return;
 
-	netif_warn(tp, link, tp->dev, "PHY reset until link up\n");
-
 	tp->phy_reset_enable(tp);
 
 out_mod_timer:
-- 
1.8.3.3
