From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Sun, 05 Oct 2008 10:34:54 -0700 (PDT)
Message-ID: <20081005.103454.247312994.davem@davemloft.net>
References: <20080930.070804.26007839.davem@davemloft.net>
	<E1KmKGd-000393-UD@gondolin.me.apana.org.au>
	<c3ca0c0f0810042145q35a451a7u706bc64fb43723fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: whydna@whydna.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34100
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755001AbYJERfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 13:35:20 -0400
In-Reply-To: <c3ca0c0f0810042145q35a451a7u706bc64fb43723fa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Andrew Dickinson" <whydna@whydna.net>
Date: Sat, 4 Oct 2008 21:45:27 -0700

> Here's the patch that Herbert's referring to.  The basic idea is that
> we have a flag which indicates whether or not we need to invalidate
> the route cache.  If any chain exceeds gc_elasticity, we set the flag
> and reschedule the timer.  In the worst-case, we'll invalidate the
> route cache once every secret_interval; in the best-case, we never
> invalidate the cache.

This is a very interesting patch and idea, but...

Eric showed clearly that on a completely normal well loaded
system, the chain lengths exceed the elasticity all the time
and it's not like these are entries we can get rid of because
their refcounts are all > 1
