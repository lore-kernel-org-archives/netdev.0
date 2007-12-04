From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: NET: ASSERT_RTNL in __dev_set_promiscuity makes debug warning
Date: Wed, 05 Dec 2007 09:38:27 +1100
Message-ID: <E1IzgPL-0006HB-00@gondolin.me.apana.org.au>
References: <000001c8365a$e0e500c0$9c94fea9@jason>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joonwpark81@gmail.com (Joonwoo Park)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4340 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751380AbXLDWif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 17:38:35 -0500
In-Reply-To: <000001c8365a$e0e500c0$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park <joonwpark81@gmail.com> wrote:
> Hi,
> dev_set_rx_mode calls __dev_set_rx_mode with softirq disabled (by netif_tx_lock_bh)
> therefore __dev_set_promiscuity can be called with softirq disabled.
> It will cause in_interrupt() to return true and ASSERT_RTNL warning.
> Is there a good solution to fix it besides blowing ASSERT_RTNL up?

We've talked this one before on netdev.  It's on my todo list to fix.
The correct solution is to untangle this so that __dev_set_promiscuity
does not get called in the first place on BH paths.

Unfortunately I've been busy so I haven't completed the patches yet.
But as this problem is not urgent let's not just put on a bandaid.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
