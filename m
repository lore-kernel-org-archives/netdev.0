From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
 layer
Date: Tue, 24 Feb 2009 23:31:15 -0800 (PST)
Message-ID: <20090224.233115.240823417.davem@davemloft.net>
References: <20090225063656.GA32635@gondor.apana.org.au>
	<1235546423.2604.556.camel@ymzhang>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	shemminger@vyatta.com
To: yanmin_zhang@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50473
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754370AbZBYHbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:31:34 -0500
In-Reply-To: <1235546423.2604.556.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Wed, 25 Feb 2009 15:20:23 +0800

> If the machines might have a couple of NICs and every NIC has CPU_NUM queues,
> binding them evenly might cause more cache-miss/ping-pong. I didn't test
> multiple receiving NICs scenario as I couldn't get enough hardware.

In the net-next-2.6 tree, since we mark incoming packets with
skb_record_rx_queue() properly, we'll make a more favorable choice of
TX queue.

You may want to figure out what that isn't behaving well in your
case.

I don't think we should do any kind of software spreading for such
capable hardware, it defeats the whole point of supporting the
multiqueue features.
