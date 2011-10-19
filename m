From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 16:24:08 +0200
Message-ID: <1319034248.1286.8.camel@jlt3.sipsolutions.net>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4)  <1319029101.4424.36.camel@jlt3.sipsolutions.net>
	 <1319029794.4424.37.camel@jlt3.sipsolutions.net>
	 <1319030740.8416.14.camel@edumazet-laptop>
	 (sfid-20111019_152616_037809_8B36A3CC) <1319031348.1286.4.camel@jlt3.sipsolutions.net>
	 <1319031856.8416.19.camel@edumazet-laptop>
	 (sfid-20111019_154501_303541_A1FD5289) <1319032638.1286.7.camel@jlt3.sipsolutions.net>
	 <1319033305.8416.29.camel@edumazet-laptop>
	 (sfid-20111019_160907_252212_044BFD93)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34176 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756342Ab1JSOYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 10:24:25 -0400
In-Reply-To: <1319033305.8416.29.camel@edumazet-laptop> (sfid-20111019_160907_252212_044BFD93)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-19 at 16:08 +0200, Eric Dumazet wrote:

> > Anyway, I guess you agree that the patches as-is aren't actually the
> > right solution since we can't sock_hold() a TX skb socket reference?
> 
> Yes, the sock_hold() could be changed by an atomic_inc_not_zero()
> 
> What about doing this ?

>  		if (likely(phydev->drv->txtstamp)) {
> +			if (!atomic_inc_not_zero(&sk->sk_refcnt))
> +				return;

Yeah that seems like it works and just drops the timestamp in case we
don't still have a live socket, which is perfectly fine.

johannes
