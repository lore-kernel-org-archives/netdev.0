From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch] (revised) net/xfrm/xfrm_policy.c: replace timer with delayed_work
Date: Tue, 6 May 2008 11:08:22 +0800
Message-ID: <20080506030822.GA14111@gondor.apana.org.au>
References: <20080216.235534.237382205.xiyou.wangcong@gmail.com> <20080427011809.GA662@gondor.apana.org.au> <20080428.225312.58450957.xiyou.wangcong@gmail.com> <20080428151342.GA12007@gondor.apana.org.au> <alpine.LFD.1.10.0804302355120.2940@localhost.localdomain> <20080501011123.GA4060@gondor.apana.org.au> <alpine.LFD.1.10.0805021323470.3349@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net, akpm@osdl.org,
	netdev@vger.kernel.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48235 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750885AbYEFDIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 23:08:32 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805021323470.3349@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 02, 2008 at 01:35:55PM +0800, WANG Cong wrote:
>
> @@ -209,16 +210,16 @@ static void xfrm_policy_timer(unsigned long data)
>  	if (warn)
>  		km_policy_expired(xp, dir, 0, 0);
>  	if (next != LONG_MAX &&
> -	    !mod_timer(&xp->timer, jiffies + make_jiffies(next)))
> +	    !schedule_delayed_work(&xp->work, make_jiffies(next)))
>  		xfrm_pol_hold(xp);

I tried it and it pretty much crashed immediately :)

The problem is that schedule_delayed_work's return value is the
opposite of mod_timer.  So you'll need to reverse the tests.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
