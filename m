From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: dummy: allocate devices with alloc_netdev_id
Date: Thu, 09 Jun 2011 00:20:55 -0700 (PDT)
Message-ID: <20110609.002055.558422517682261395.davem@davemloft.net>
References: <1307433593.3091.3.camel@edumazet-laptop>
	<BANLkTinVNkcznN5kPpje4cptjCKfWW6s-w@mail.gmail.com>
	<20110607.022926.472309688813629515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: lucian.grijincu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926Ab1FIHU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 03:20:59 -0400
In-Reply-To: <20110607.022926.472309688813629515.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 07 Jun 2011 02:29:26 -0700 (PDT)

> From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
> Date: Tue, 7 Jun 2011 11:30:38 +0300
> 
>> @David: I see [1][2] that you marked the patches as Rejected. If it's
>> not a script that sends all my patches to /dev/null because of the
>> 100+ patch set I sent a while back, could you tell me why you rejected
>> the patches?
> 
> I misfired while changing patch states earlier today, I put them back
> into "Under Review"

So I took a look again, you're patches introduce problems.

We don't do the instance allocation and (more importantly) conflict
validation of the netdev name in alloc_netdev_mqs(), we do it when the
netdev is registered.

So with your patch some other entity could rename a random netdev
to "dummy62" in between the alloc_netdev_id() call and the register
and the register will fail erroneously.

I really don't like this optimization, sorry.  Make dev_alloc_name()
less stupid instead.

