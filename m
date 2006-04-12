From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] atm: clip causes unregister hang
Date: Thu, 13 Apr 2006 06:25:51 +1000
Message-ID: <20060412202551.GA20085@gondor.apana.org.au>
References: <20060412105545.3b089dd8@localhost.localdomain> <E1FTjlM-00050V-00@gondolin.me.apana.org.au> <20060412124533.14e0c4ff@localhost.localdomain> <20060412200015.GA19878@gondor.apana.org.au> <20060412131527.71f42d58@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58127 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932226AbWDLU0P
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 16:26:15 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060412131527.71f42d58@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2006 at 01:15:27PM -0700, Stephen Hemminger wrote:
> 
> If atm_init_atmarp has not been done, then to_atamarpd is a nop because
> atmarpd == NULL.

Good point.  But I don't see anything that will keep atmarpd from
closing the socket.  Previously the unregister_notifier calls served
as sort of a barrier which prevented the close from proceeding until
we're out of the event handlers.

Now that thw unregister_notifier calls have been moved we need some
other way of ensuring that.  Holding the RTNL should be enough.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
