From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Mon, 11 Jun 2012 04:28:13 -0700 (PDT)
Message-ID: <20120611.042813.401909584318598192.davem@davemloft.net>
References: <20120611.022911.885347106959530782.davem@davemloft.net>
	<20120611111659.GK27795@secunet.com>
	<20120611.042024.1022194952800114410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab2FKL2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 07:28:14 -0400
In-Reply-To: <20120611.042024.1022194952800114410.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 11 Jun 2012 04:20:24 -0700 (PDT)

> We need to find a way to implement this then, in such a way
> that we have the route context used to send the ping packet
> out.

The problem is RAW sockets right?  If so, then this is where the
fix belongs.

There is nothing preventing the RAW socket code from remembering the
last route used, as well as the flow4 key used to look it up, and
processing the PMTU message appropriately in raw_err() using that
remembered information if the flow4 key matches.
