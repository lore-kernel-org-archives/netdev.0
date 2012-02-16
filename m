From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Thu, 16 Feb 2012 08:46:37 +0100
Message-ID: <20120216074637.GA6208@electric-eye.fr.zoreil.com>
References: <20120215163748.GA3998@elliptictech.com> <1329333239.2469.3.camel@edumazet-laptop> <20120215232303.GB31463@electric-eye.fr.zoreil.com> <33249D172FBD4AE09E24D4F24E973BD9@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	"'Nick Bowler'" <nbowler@elliptictech.com>, netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53842 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174Ab2BPH7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 02:59:07 -0500
Content-Disposition: inline
In-Reply-To: <33249D172FBD4AE09E24D4F24E973BD9@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> Please add Cfg9346_Unlock before calling rtl_hw_jumbo_enable or
> hw_jumbo_disable.
> And, add Cfg9346_lock after calling rlt_hw_jumbo_enable or hw_jumbo_disable. 

Thanks.

I am testing it now.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5eb6858..81e6ea2 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3833,12 +3833,20 @@ static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
 
 static void rtl_hw_jumbo_enable(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	rtl_generic_op(tp, tp->jumbo_ops.enable);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
 }
 
 static void rtl_hw_jumbo_disable(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	rtl_generic_op(tp, tp->jumbo_ops.disable);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
 }
 
 static void r8168c_hw_jumbo_enable(struct rtl8169_private *tp)
