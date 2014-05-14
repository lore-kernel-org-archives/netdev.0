From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/8] tipc: compensate for double accounting
 in socket rcv buffer
Date: Wed, 14 May 2014 13:37:16 -0400 (EDT)
Message-ID: <20140514.133716.106221573887805156.davem@davemloft.net>
References: <1400060355-26308-3-git-send-email-jon.maloy@ericsson.com>
	<1400068021.7973.78.camel@edumazet-glaptop2.roam.corp.google.com>
	<A2BAEFC30C8FD34388F02C9B3121859D1C25134A@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbaENRhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 13:37:20 -0400
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D1C25134A@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 14 May 2014 12:53:45 +0000

> Because TCP can throw away packet in such situations, and TIPC cannot.

Just want to state for the record that I consider any transport,
even over directly connected ethernet, that cannot retransmit at
the socket level and does not accomodate packet reordering, to be
fundamentally flawed.

Even if you can absolutely prove that ethernet is %100 drop free and
will never reorder your frames, some of those things can always happen
in the system itself since memory is not infinite and your protocol
is not the only consumer of kernel memory in the system.

You have to accomodate packet drops, at any level, and recover in some
reasonable way from this.

So even with byte based flow control, TIPC I think will still have
fundamental issues with data handling.
