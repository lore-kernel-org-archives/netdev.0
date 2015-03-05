From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/7] switchdev: add IPv4 routing offload
Date: Thu, 05 Mar 2015 00:07:17 -0500 (EST)
Message-ID: <20150305.000717.479876439702052068.davem@davemloft.net>
References: <CAE4R7bDBJye388V+itU9XqFNjruf0GcbXWFydx60fghiZp+NQw@mail.gmail.com>
	<20150304.160604.2259380248170644628.davem@davemloft.net>
	<CAE4R7bDTV38bR2Oo2nfO6gFQQBhC4avmWdYeK_2sj1bqZWQiEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbbCEFHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 00:07:19 -0500
In-Reply-To: <CAE4R7bDTV38bR2Oo2nfO6gFQQBhC4avmWdYeK_2sj1bqZWQiEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Wed, 4 Mar 2015 20:50:28 -0800

> I don't know what to do for v4.  Bummer, we got pretty close.  My only
> ideas right now involve more code to handling unwinding some routes
> from hw when related route fails to install to hw.

Scott:

1) route ADD

	driver has NULL ndo_op, do nothing, install sw route

	ndo_op SUCCESS, return 0, all is good and the caller sets the
	external bit

	ndo_op FAILURE, returns any error code, any and all external
	routes are removed with DEL ndo_op, all external bits are
	cleared

2) route DEL

	driver has NULL ndo_op, do nothing

	ndo_op SUCCESS, return 0, clear external bit

	ndo_op FAILURE, pass failure up the delete call stack
