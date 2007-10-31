From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/5] Make nicer CONFIG_NET_NS=n case code
Date: Wed, 31 Oct 2007 16:05:46 -0600
Message-ID: <m1hck7hrd1.fsf@ebiederm.dsl.xmission.com>
References: <4728D54F.2080208@openvz.org>
	<20071031194924.2436843e.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:45176 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761536AbXJaWGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 18:06:14 -0400
In-Reply-To: <20071031194924.2436843e.dada1@cosmosbay.com> (Eric Dumazet's
	message of "Wed, 31 Oct 2007 19:49:24 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> writes:


> Definitly wanted here. Thank you.
> One more refcounting on each socket creation/deletion was expensive.

Really?  Have you actually measured that?  If the overhead is
measurable and expensive we may want to look at per cpu counters or
something like that.  So far I don't have any numbers that say any
of the network namespace work inherently has any overhead.

> Maybe we can add a macro to get nd_net from a "struct net_device"
> so that every instance of
>
> if (dev->nd_net != &init_net)
>     goto drop;
>
> can also be optimized away if !CONFIG_NET_NS

Well that extra check should be removed once we finish converting
those code paths.  So I'm not too worried.

If this becomes a big issue I can dig up my old code that
replaced struct net * with a net_t typedef and used functions
for all of the comparisons and allowed everything to be compiled
away.

Trouble was it was sufficiently different that it was just enough
different that people could not immediately understand the code.

Eric
