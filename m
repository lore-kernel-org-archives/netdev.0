From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] tulip: napi full quantum bug
Date: Thu, 13 Dec 2007 09:35:45 -0800
Message-ID: <20071213093545.436b8f8e@freepuppy.rosehill>
References: <1dd3c7c0711291113v5c197561m3121afc8f676db5f@mail.gmail.com>
	<20071129133622.56301c9d@freepuppy.rosehill>
	<1dd3c7c0711291430r1086a46ajc4af199903a7a65e@mail.gmail.com>
	<20071207161435.42ae67f8@freepuppy.rosehill>
	<1dd3c7c0712080344q414fe7c3w32d7ca6d900a52b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kristjan <kristjan.ugrin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46589 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758738AbXLMRhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:37:35 -0500
In-Reply-To: <1dd3c7c0712080344q414fe7c3w32d7ca6d900a52b5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should fix the kernel warn/oops reported while routing.

The tulip driver has a fencepost bug with new NAPI in 2.6.24
It has an off by one bug if a full quantum is reached.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/tulip/interrupt.c	2007-12-13 09:20:27.000000000 -0800
+++ b/drivers/net/tulip/interrupt.c	2007-12-13 09:23:34.000000000 -0800
@@ -151,7 +151,8 @@ int tulip_poll(struct napi_struct *napi,
                        if (tulip_debug > 5)
                                printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
                                       dev->name, entry, status);
-		       if (work_done++ >= budget)
+
+		       if (++work_done >= budget)
                                goto not_done;
 
                        if ((status & 0x38008300) != 0x0300) {
