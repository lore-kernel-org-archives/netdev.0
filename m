From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 14:03:07 +1000
Message-ID: <20060531040307.GA6447@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:9476 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751644AbWEaED7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 00:03:59 -0400
To: "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

It has occured to me that the function netif_tx_disable may be unsafe
when used in drivers that do lockless transmission.  In particular,
the function relies on taking the xmit_lock to ensure that no further
transmissions will occur until the queue is started again.

However, lockless drivers do not take the xmit_lock so this method
is ineffective.  Such drivers need to do their own checking inside
whatever locks that they do take.  For example, tg3 could get around
this by checking whether the queue is stopped in its hard_start_xmit
function.

I must say though that I'm becoming less and less impressed by the
lockless feature based on the number of problems that it has caused.
Does anyone have any hard figures as to its effectiveness (excluding
any stats relating to the loopback interface which can be easily
separated from normal NIC drivers).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
