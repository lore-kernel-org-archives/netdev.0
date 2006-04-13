From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] atm: clip timer race
Date: Thu, 13 Apr 2006 14:08:29 -0700
Message-ID: <adaek01p4j6.fsf@cisco.com>
References: <20060412105545.3b089dd8@localhost.localdomain>
	<E1FTjlM-00050V-00@gondolin.me.apana.org.au>
	<20060412124533.14e0c4ff@localhost.localdomain>
	<20060412200015.GA19878@gondor.apana.org.au>
	<20060412131527.71f42d58@localhost.localdomain>
	<20060412202551.GA20085@gondor.apana.org.au>
	<20060412145254.4dd21be6@localhost.localdomain>
	<20060412154214.1dd4117d@localhost.localdomain>
	<20060413124534.GA25333@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, davem@davemloft.net,
	chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from test-iport-3.cisco.com ([171.71.176.78]:41014 "EHLO
	test-iport-3.cisco.com") by vger.kernel.org with ESMTP
	id S964971AbWDMVIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 17:08:34 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060413124534.GA25333@gondor.apana.org.au> (Herbert Xu's message of "Thu, 13 Apr 2006 22:45:34 +1000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Herbert> I don't think this is enough though since this timer is
    Herbert> one of those self-rescheduling timers.  You need to
    Herbert> provide some sort of a flag for it to stop scheduling
    Herbert> itself and synchronise it properly.

I'm probably missing an obvious race but it seems del_timer_sync()
should be fine on a timer that reschedules itself.  del_timer_sync()
loops until try_to_del_timer_sync() succeeds, and
try_to_del_timer_sync() will fail unless the timer being killed is not
running (and it does this test with the timer base lock held).

OK, how am I being stupid?

 - R.
