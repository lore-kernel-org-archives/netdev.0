From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] 2.6.19-rc4 - netlink messages created with bad flags in soft_irq context
Date: Wed, 01 Nov 2006 14:50:57 +1100
Message-ID: <E1Gf77x-0002Qt-00@gondolin.me.apana.org.au>
References: <20061031220559.GA10119@gospo.rdu.redhat.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47883 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1423933AbWKADvO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 22:51:14 -0500
To: andy@greyhouse.net (Andy Gospodarek)
In-Reply-To: <20061031220559.GA10119@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:
> I've got a kernel built where 
> 
> CONFIG_DEBUG_SPINLOCK_SLEEP=y
> 
> is in the config and I've noticed some interesting behavior when
> bringing up bonds in balance-alb mode.  When I start to enslave devices
> to a bond I get the following in the ring buffer:
> 
> BUG: sleeping function called from invalid context at mm/slab.c:3007
> in_atomic():1, irqs_disabled():0
> 
> along with a nice backtrace of the error that pointed to the cause of
> this message.  The bonding code was calling for the device to set its
> MAC address and the netlink message that would be send as a result of
> this notification was being created with the flag GFP_KERNEL instead of
> GFP_ATOMIC.  

The bonding driver is known to be broken in places where it tries to
call into the network stack in atomic contexts where it shouldn't.

So please verify whether this is the case here before changing netlink.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
