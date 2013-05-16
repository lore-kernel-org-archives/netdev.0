From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix mv643xx_eth.c lockdep violation
Date: Thu, 16 May 2013 09:21:34 -0700
Message-ID: <1368721294.3301.55.camel@edumazet-glaptop>
References: <20130516161313.GS18614@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:63557 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab3EPQVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 12:21:48 -0400
Received: by mail-pb0-f50.google.com with SMTP id um15so2479170pbc.37
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 09:21:48 -0700 (PDT)
In-Reply-To: <20130516161313.GS18614@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 17:13 +0100, Russell King - ARM Linux wrote:

> It seems that txq_reclaim() takes the netif tx lock:
> 
>         __netif_tx_lock(nq, smp_processor_id());
> 
> in a context outside of softirq context, and thus is susceptible to
> deadlock should an interrupt occur.
> 
> Disable IRQs around the call to txq_deinit() to avoid this issue.

Hmm, I would use __netif_tx_lock_bh()/__netif_tx_unlock_bh() in
txq_reclaim() instead...
