From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: netdevice queueing / sendmsg issue?
Date: Sat, 04 Aug 2007 00:18:25 +0200
Message-ID: <m3ps24l0su.fsf@maximus.localdomain>
References: <m3lkd0upx8.fsf@maximus.localdomain>
	<20070728.224959.74562336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:54108 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763345AbXHCWS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 18:18:28 -0400
In-Reply-To: <20070728.224959.74562336.davem@davemloft.net> (David Miller's message of "Sat, 28 Jul 2007 22:49:59 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> Software interrupts might be getting lost, dev_kfree_skb_irq() has to
> queue the kfree_skb() to soft IRQ.
>
> Therefore, dev_kfree_skb_irq() will only work properly from hardware
> interrupt context, where we will return and thus run the scheduled
> software interrupt.

Problem solved, stupid user mistake.
I was using netif_start_queue() instead of netif_wake_queue().
-- 
Krzysztof Halasa
