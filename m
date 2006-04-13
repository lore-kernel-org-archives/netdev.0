From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] atm: clip timer race
Date: Fri, 14 Apr 2006 08:11:14 +1000
Message-ID: <E1FUA1y-0007XP-00@gondolin.me.apana.org.au>
References: <adaek01p4j6.fsf@cisco.com>
Cc: herbert@gondor.apana.org.au, shemminger@osdl.org,
	davem@davemloft.net, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:8720 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932470AbWDMWLn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 18:11:43 -0400
To: rdreier@cisco.com (Roland Dreier)
In-Reply-To: <adaek01p4j6.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier <rdreier@cisco.com> wrote:
> 
> I'm probably missing an obvious race but it seems del_timer_sync()
> should be fine on a timer that reschedules itself.  del_timer_sync()
> loops until try_to_del_timer_sync() succeeds, and
> try_to_del_timer_sync() will fail unless the timer being killed is not
> running (and it does this test with the timer base lock held).
> 
> OK, how am I being stupid?

No you're definitely right.  I just missed the fix that was made
to del_timer_sync last year.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
