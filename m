From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] skge: add GRO support
Date: Tue, 31 Aug 2010 18:31:05 -0700
Message-ID: <20100831183105.03b0f2bc@nehalam>
References: <1283293956.2198.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35411 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749Ab0IABbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 21:31:07 -0400
In-Reply-To: <1283293956.2198.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Sep 2010 00:32:36 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> @@ -3193,7 +3192,7 @@ static int skge_poll(struct napi_struct *napi, int to_do)
>  		unsigned long flags;
>  
>  		spin_lock_irqsave(&hw->hw_lock, flags);
> -		__napi_complete(napi);
> +		napi_complete(napi);

This adds a redundant irq_save/irq_restore in the packet
receive path.

In the case of skge, since the both ports share a single
IRQ mask register, the lock is there to make sure that updates
to the mask register doesn't race between NAPI finishing
on one port and IRQ on other port changing same IRQ mask register.


