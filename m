From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.18 2/3] tg3: Convert to non-LLTX
Date: Sat, 17 Jun 2006 21:58:56 -0700 (PDT)
Message-ID: <20060617.215856.03979898.davem@davemloft.net>
References: <1149536852.13155.7.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38370
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932096AbWFRE66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 00:58:58 -0400
To: mchan@broadcom.com
In-Reply-To: <1149536852.13155.7.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 05 Jun 2006 12:47:32 -0700

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

Applied, thanks a lot.
