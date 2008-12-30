From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] EtherExpress16: fix printing timed out status
Date: Mon, 29 Dec 2008 18:42:44 -0800 (PST)
Message-ID: <20081229.184244.198741009.davem@davemloft.net>
References: <4957ED09.2040806@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: philb@gnu.org, netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752254AbYL3Cml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 21:42:41 -0500
In-Reply-To: <4957ED09.2040806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 28 Dec 2008 22:18:01 +0100

> in drivers/net/eexpress.c:558, function unstick_cu()
> 
> while (!SCB_complete(rsst=scb_status(dev))) {
> 	...
> 	if (...)
> 		printk(KERN_WARNING "%s: Reset timed out status %04x, retrying...\n",
>                                                        dev->name,rsst);
> }
> 
> but this will become 
> 
> while (!((rsst = scb_status(dev) & 0x8000) != 0) ...
> 
> because of the macro:
> 
> #define SCB_complete(s) ((s&0x8000)!=0)
> 
> so rsst can only become either 0x8000 or 0, but in the latter case the loop ends,
> I think the wrong timed out status is printed. This also cleans up similar macros.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thank you.
