From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 25 Dec 2008 18:00:51 -0800 (PST)
Message-ID: <20081225.180051.116331110.davem@davemloft.net>
References: <Pine.LNX.4.64.0812182040120.11995@wrl-59.cs.helsinki.fi>
	<20081225.171146.208898156.davem@davemloft.net>
	<20081226014739.GA11880@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, kuznet@ms2.inr.ac.ru, ptesarik@suse.cz,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752310AbYLZCAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 21:00:49 -0500
In-Reply-To: <20081226014739.GA11880@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 26 Dec 2008 12:47:39 +1100

> If all these packets are delivered in order, then what'll happen
> is that RCV.UP starts out at 65535, and once the final segment is
> delivered it'll be updated to 66240.
> 
> If out-of-order delivery occurs and the final segment arrives earlier,
> then all that'll happen is that RCV.UP will hit 66240 earlier, which
> is not an issue since all subsequent urgent pointers will be less and
> hence ignored.

So it all hinges on how the receiver updates his URG pointer.  This is
what legitimizes a sender advertising a changing URG pointer.

So it works, but it isn't the nicest thing in the world :-)
