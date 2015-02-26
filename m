From: David Miller <davem@davemloft.net>
Subject: Re: ARP resolving for switch drivers
Date: Thu, 26 Feb 2015 01:18:36 -0500 (EST)
Message-ID: <20150226.011836.1083589883979886399.davem@davemloft.net>
References: <20150222.011109.109641758308879034.davem@davemloft.net>
	<CAE4R7bCV1+oA8i52i8g=+yEwsoApcAQq5-WeTxgN40v-ai7y+A@mail.gmail.com>
	<CAE4R7bDnrMZSsZeZmYkT8HhkXUpgnedBo8VX5iEtyJmzJ7gV5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbBZGSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 01:18:40 -0500
In-Reply-To: <CAE4R7bDnrMZSsZeZmYkT8HhkXUpgnedBo8VX5iEtyJmzJ7gV5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Wed, 25 Feb 2015 21:08:30 -0800

> 1) Routes that overlap tables, or how to assign priority.  I'll look
> at the RFC you sent for collapsing local/main tables.  For now, I used
> fib_info->fib_priority for the priority in the rocker L3 table.  Maybe
> that's good enough once local/main are collapsed?  But for other
> tables, I'm not sure if fib_info->fib_priority will be sufficient.  I
> probably need some guidance here.

It should work with my local/main unification work.

You just have to abort hw offloading if any FIB rule modifications
happen. (ie. all the spots that set net->ipv4.fib_has_custom_rules)
