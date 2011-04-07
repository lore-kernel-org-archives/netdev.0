From: David Miller <davem@davemloft.net>
Subject: Re: problem of "ipv4: revert Set rt->rt_iif more sanely on output
 routes."
Date: Thu, 07 Apr 2011 14:03:33 -0700 (PDT)
Message-ID: <20110407.140333.189683738.davem@davemloft.net>
References: <20110406.224244.104071339.davem@davemloft.net>
	<877hb6sf43.fsf@devron.myhome.or.jp>
	<8739lusbvz.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hirofumi@mail.parknet.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60007
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751144Ab1DGVEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 17:04:10 -0400
In-Reply-To: <8739lusbvz.fsf@devron.myhome.or.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date: Thu, 07 Apr 2011 17:29:04 +0900

> I'm not sure
> 
> +	rth->rt_route_iif = 0;
> +	rth->rt_iif	= oldflp4->flowi4_oif ? : dev_out->ifindex;
> 
> is correct one or not. Please review.

I am pretty sure this is indeed correct.

In old code this read:

	rth->rt_iif	= oldflp->oif ? : dev_out->ifindex;

And rt->fl.iif was left without explicit setting, and thus left
as zero (dst_alloc() use to bzero entire rtable object).

So new code is equivalent and provides the necessary semantics.

I think your patch is correct and I will add it to net-2.6, thanks
again!

