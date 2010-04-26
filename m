From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 11:04:32 -0700 (PDT)
Message-ID: <20100426.110432.104061817.davem@davemloft.net>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
	<1272302434.19143.76.camel@edumazet-laptop>
	<q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751118Ab0DZSE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:04:26 -0400
In-Reply-To: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 26 Apr 2010 10:38:27 -0700

> It would appear that way :-(.  I was going to ping Broadcom folks to
> see if there's support for UDP.

I'm pretty sure there isn't at this point.

We'll need to elide setting ->rxhash for non-TCP packets.  I bet that
the ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE field might be usable to making
this decision, but if not in the worst case we'll need to parse the
VLAN/ETH and IP4/IP6 headers to figure out the protocol.

Damn, I'm so pissed off about this.  This ruins everything!

How damn hard is it to add two 16-bit ports to the hash regardless of
protocol?
