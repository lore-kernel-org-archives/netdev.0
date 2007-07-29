From: David Miller <davem@davemloft.net>
Subject: Re: netdevice queueing / sendmsg issue?
Date: Sat, 28 Jul 2007 22:49:59 -0700 (PDT)
Message-ID: <20070728.224959.74562336.davem@davemloft.net>
References: <m3lkd0upx8.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44535
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755270AbXG2Ft7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 01:49:59 -0400
In-Reply-To: <m3lkd0upx8.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sun, 29 Jul 2007 00:25:07 +0200

> I wonder if it's dev_kfree_skb_irq() which should but fails to wake
> the thing up?

Software interrupts might be getting lost, dev_kfree_skb_irq() has to
queue the kfree_skb() to soft IRQ.

Therefore, dev_kfree_skb_irq() will only work properly from hardware
interrupt context, where we will return and thus run the scheduled
software interrupt.

So some things to check out are whether the driver is invoking
dev_kfree_skb_irq() in the right context, whether ARM might have some
software interrupt processing preculiarity, etc.
