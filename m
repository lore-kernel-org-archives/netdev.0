From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch netdev-2.6 3/3] r8169: simplify trick if() expression
Date: Fri, 22 Oct 2004 21:49:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041023014923.GB32031@tuxdriver.com>
References: <20041022005737.GA1945@tuxdriver.com> <20041022202851.GB4216@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041022202851.GB4216@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Simplify tricky if() expression in rtl8169_vlan_rx_register().

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
You're probably right -- the "if ((tp->vlgrp = grp))" line is probably
a little TOO clever... :-)

 drivers/net/r8169.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

--- ./drivers/net/r8169.c.orig	2004-10-22 21:44:06.050154952 -0400
+++ ./drivers/net/r8169.c	2004-10-22 21:44:26.228087440 -0400
@@ -703,7 +703,8 @@ static void rtl8169_vlan_rx_register(str
 	unsigned long flags;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	if ((tp->vlgrp = grp))
+	tp->vlgrp = grp;
+	if (tp->vlgrp)
 		tp->cp_cmd |= RxVlan;
 	else
 		tp->cp_cmd &= ~RxVlan;
