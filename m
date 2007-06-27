From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5 2.6.22-rc6] L2TP: PPP over L2TP driver core
Date: Wed, 27 Jun 2007 15:52:48 -0700 (PDT)
Message-ID: <20070627.155248.57444719.davem@davemloft.net>
References: <200706272220.l5RMKciF004946@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751433AbXF0Ww2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 18:52:28 -0400
In-Reply-To: <200706272220.l5RMKciF004946@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Wed, 27 Jun 2007 23:20:38 +0100

> This driver handles only L2TP data frames; control frames are handled
> by a userspace application. It implements L2TP using the PPPoX socket
> family. There is a PPPoX socket for each L2TP session in an L2TP tunnel.
> PPP data within each session is passed through the kernel's
> PPP subsystem via this driver. Kernel parameters of each socket can be
> read or modified using ioctl() or [gs]etsockopt() calls.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied, and I added the following build warning fix on top:

commit 24c65a03093b1c33fb90bbae6a024d161faa437a
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Jun 27 15:52:25 2007 -0700

    [PPPOL2TP]: Use proper printf format specifier for size_t.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 8a6bff5..5891a0f 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -890,11 +890,11 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 	/* Debug */
 	if (session->send_seq)
 		PRINTK(session->debug, PPPOL2TP_MSG_DATA, KERN_DEBUG,
-		       "%s: send %d bytes, ns=%hu\n", session->name,
+		       "%s: send %Zd bytes, ns=%hu\n", session->name,
 		       total_len, session->ns - 1);
 	else
 		PRINTK(session->debug, PPPOL2TP_MSG_DATA, KERN_DEBUG,
-		       "%s: send %d bytes\n", session->name, total_len);
+		       "%s: send %Zd bytes\n", session->name, total_len);
 
 	if (session->debug & PPPOL2TP_MSG_DATA) {
 		int i;
