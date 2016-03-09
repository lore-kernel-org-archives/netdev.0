From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 09 Mar 2016 12:19:28 -0500 (EST)
Message-ID: <20160309.121928.103638956202937455.davem@davemloft.net>
References: <1457281392.2663.5.camel@edumazet-ThinkPad-T530>
	<20160306170641.GA8820@uranus.lan>
	<20160309163919.GJ2207@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933571AbcCIRTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:19:31 -0500
In-Reply-To: <20160309163919.GJ2207@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 9 Mar 2016 19:39:19 +0300

>    9.21%  [kernel]                    [k] nf_ct_iterate_cleanup
 ...
>  Release
>  -------
>   24.26%  [kernel]                    [k] _raw_spin_lock
>   17.55%  [kernel]                    [k] preempt_count_add
>   14.81%  [kernel]                    [k] __local_bh_enable_ip
>   14.17%  [kernel]                    [k] preempt_count_sub
>   10.10%  [kernel]                    [k] nf_ct_iterate_cleanup
 ...
> The main problem still I think is that we allow to request
> as many inet addresses as there is enough free memory and
> of course kernel can't handle all in O(1) time, all resources
> must be released so there always be some lagging moment. Thus
> maybe introducing limits would be a good idea for sysadmins.

Primary problem seems to be netfilter conntrack.

It's at least 10 times more expensive than any of the other
operations and probably is where all of the lock banging is
coming from.

I'm not adding a limit when there is so much low hanging fruit
remaining, no way.
