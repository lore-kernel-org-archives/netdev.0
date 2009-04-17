From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] loopback: better handling of packet drops
Date: Fri, 17 Apr 2009 03:51:12 -0700 (PDT)
Message-ID: <20090417.035112.171173490.davem@davemloft.net>
References: <49E84B99.1080502@cosmosbay.com>
	<49E854A4.1010204@cosmosbay.com>
	<49E85AFD.6080407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49339
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759920AbZDQKvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 06:51:21 -0400
In-Reply-To: <49E85AFD.6080407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 17 Apr 2009 12:33:33 +0200

> Splitting netif_rx() with a helper function boosts tbench
> performance by 1%, because we can avoid two tests (about netpoll and
> timestamping)

Loopback is not a special device no matter how much you wish
it might be :-)

This is why I haven't really pursued any further those patches I
showed you that treat local TCP connections specially, it just had the
realy possibility to break clever things people might be doing over
loopback using the packet scheduler classifier and packet scheduler
actions.

I also think it is valid to use netpoll over loopback, especially for
testing.

So please undo this part of the patch.  You always try to combine
multiple distinct changes, and I would have taken just your TX drop
change if you hadn't added this __netif_rx() stuff to it :-(
