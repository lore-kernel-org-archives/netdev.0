From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
 layer
Date: Wed, 04 Mar 2009 01:39:37 -0800 (PST)
Message-ID: <20090304.013937.129768263.davem@davemloft.net>
References: <1235546423.2604.556.camel@ymzhang>
	<20090224.233115.240823417.davem@davemloft.net>
	<1236158868.2567.93.camel@ymzhang>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	shemminger@vyatta.com
To: yanmin_zhang@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35837
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750985AbZCDJjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 04:39:53 -0500
In-Reply-To: <1236158868.2567.93.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Wed, 04 Mar 2009 17:27:48 +0800

> Both the new skb_record_rx_queue and current kernel have an
> assumption on multi-queue. The assumption is it's best to send out
> packets from the TX of the same number of queue like the one of RX
> if the receved packets are related to the out packets. Or more
> direct speaking is we need send packets on the same cpu on which we
> receive them. The start point is that could reduce skb and data
> cache miss.

We have to use the same TX queue for all packets for the same
connection flow (same src/dst IP address and ports) otherwise
we introduce reordering.

Herbert brought this up, now I have explicitly brought this up,
and you cannot ignore this issue.

You must not knowingly reorder packets, and using different TX
queues for packets within the same flow does that.
