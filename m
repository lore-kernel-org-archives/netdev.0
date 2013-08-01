From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: bump genid when delete/add address
Date: Thu, 01 Aug 2013 16:34:23 -0700 (PDT)
Message-ID: <20130801.163423.349667433630759733.davem@davemloft.net>
References: <1375350284-32725-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, jmorris@namei.org,
	hannes@stressinduktion.org, vyasevich@gmail.com,
	netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484Ab3HAXeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 19:34:24 -0400
In-Reply-To: <1375350284-32725-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Thu, 1 Aug 2013 17:44:44 +0800

>      Server           Client
> 2001:1::803/64  <-> 2001:1::805/64
> 2001:2::804/64  <-> 2001:2::806/64
> 
> Server side fib binary tree looks like this:
> 
>                                    (2001:/64)
>                                    /
>                                   /
>                    ffff88002103c380
>                  /                 \
>      (2)        /                   \
>  (2001::803/128)                     ffff880037ac07c0
>                                     /               \
>                                    /                 \  (3)
>                       ffff880037ac0640               (2001::806/128)
>                        /             \
>              (1)      /               \
>         (2001::804/128)               (2001::805/128)
> 
> Delete 2001::804/64 won't cause prefix route deleted as well as rt in (3)
> destinate to 2001::806 with source address as 2001::804/64. That's because
> 2001::803/64 is still alive, which make onlink=1 in ipv6_del_addr, this is
> where the substantial difference between same prefix configuration and
> different prefix configuration :) So packet are still transmitted out to
> 2001::806 with source address as 2001::804/64.
> 
> So bump genid will clear rt in (3), and up layer protocol will eventually
> find the right one for themselves.
> 
> This problem arised from the discussion in here:
> http://marc.info/?l=linux-netdev&m=137404469219410&w=4
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Applied, thanks.
