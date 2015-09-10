From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Wed, 09 Sep 2015 17:16:00 -0700 (PDT)
Message-ID: <20150909.171600.1487892650387164045.davem@davemloft.net>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbbIJAQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 20:16:01 -0400
In-Reply-To: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed,  9 Sep 2015 17:03:01 -0300

> So the fix then is to invert the initialization order inside
> register_pernet_subsys() so that the control socket is created by last
> and also block socket creation if netns initialization wasn't yet
> performed.

If we really need to we could make ->create() fail with -EAFNOSUPPORT
if kern==1 until the protocol is fully setup.

Or, instead of failing, we could make such ->create() calls block
until the control sock init is complete or fails.

We have actually several visibility issues wrt. control sockets on
protocol init, in general.

For example, such control sockets can briefly be hashed and visible
to socket dumps and packet input.

A lot of really tricky issues involved here.
