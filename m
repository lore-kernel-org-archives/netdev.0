From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Fri, 21 Apr 2006 12:37:36 +1000
Message-ID: <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>
References: <1145578214.3195.6.camel@rh4>
Cc: herbert@gondor.apana.org.au, shawvrana@gmail.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33555 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932213AbWDUChs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 22:37:48 -0400
To: mchan@broadcom.com (Michael Chan)
In-Reply-To: <1145578214.3195.6.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan <mchan@broadcom.com> wrote:
> 
> In tg3_remove_one(), we call flush_scheduled_work() in case the
> reset_task is still pending. Here, it is safe to call

Great.

> flush_scheduled_work() because we're not holding the rtnl. Again, when

Hmm doing a quick grep seems to indicate that quite a number of drivers
do this in netdev->close or other callbacks under RTNL.  This means that
they're all vulnerable to the linkwatch deadlock that you alluded to.

Rather than dealing with this individually in each driver perhaps we should
come up with a more centralised solution?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
