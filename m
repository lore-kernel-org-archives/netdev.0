From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7 net-next] tg3: Change default number of tx rings to
 1.
Date: Fri, 28 Sep 2012 00:49:12 -0400 (EDT)
Message-ID: <20120928.004912.1130579693973926556.davem@davemloft.net>
References: <1348698769-760-7-git-send-email-mchan@broadcom.com>
	<20120927.192345.2124577537241070059.davem@davemloft.net>
	<1348807471.7220.138.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272Ab2I1EtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 00:49:14 -0400
In-Reply-To: <1348807471.7220.138.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 27 Sep 2012 21:44:31 -0700

> In the simplest case, assume you have 2 TCP streams running in opposite
> directions.  The TX traffic (mostly TSO) will hash to one tx ring.  The
> ACKs for the incoming data on a different TCP connection will hash to
> another TX ring.  The hardware fetches one complete TSO packet from the
> first ring (up to 64K data) before servicing the other TX ring.  And
> when it gets to the other TX ring, it will fetch only one packet (one
> 64-byte ACK packet in this case) and then immediately switches back to
> the 1st ring (filled with more TSO packets).  In reality, there may be
> over 10 ACK packets waiting in the 2nd ring because a lot of incoming
> data has been received and ACKed during this time.  Because the ACKs are
> going out so slowly, the incoming throughput slows to a trickle.

Thanks for the explanation, this is the kind of text that belongs in
the commit message.  Otherwise the next person who reads the patch,
like me, will ask why this is being done.

> Our other devices don't do this simple Round-robin tx scheduling.
> Instead, there are independent DMA channels fetching and interleaving tx
> data from multiple rings.

Ok.

Please respin your patch set, adding the detailed explanation you gave
me here to the TX queue change, and I will apply it.

Thanks.
