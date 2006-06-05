From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.18 2/3] tg3: Convert to non-LLTX
Date: Mon, 5 Jun 2006 15:58:34 -0700
Message-ID: <20060605155834.031d37a2@localhost.localdomain>
References: <1149536852.13155.7.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:57261 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750749AbWFEW7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 18:59:02 -0400
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1149536852.13155.7.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 05 Jun 2006 12:47:32 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> Herbert Xu pointed out that it is unsafe to call netif_tx_disable()
> from LLTX drivers because it uses dev->xmit_lock to synchronize
> whereas LLTX drivers use private locks.
> 
> Convert tg3 to non-LLTX to fix this issue. tg3 is a lockless driver
> where hard_start_xmit and tx completion handling can run concurrently
> under normal conditions. A tx_lock is only needed to prevent
> netif_stop_queue and netif_wake_queue race condtions when the queue
> is full.
> 
> So whether we use LLTX or non-LLTX, it makes practically no
> difference.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Since you are going more lockless, you probably need memory barriers.

I don't feel although that comfortable with the lockless driver model as is.
Perhaps there is something simpler that could be done with a ring model and
some atomic primitives like cmpxchg()?
