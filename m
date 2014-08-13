From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a
 tasklet from ldc_rx path
Date: Tue, 12 Aug 2014 21:31:57 -0700 (PDT)
Message-ID: <20140812.213157.60038488349789826.davem@davemloft.net>
References: <20140812.151352.2235795686370279748.davem@davemloft.net>
	<20140813015817.GA13600@oracle.com>
	<163B73C6-95EF-4398-B399-ECD5B95F5EC8@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: Raghuram.Kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaHMEb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 00:31:58 -0400
In-Reply-To: <163B73C6-95EF-4398-B399-ECD5B95F5EC8@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Date: Tue, 12 Aug 2014 21:26:28 -0700

> One important point to keep in mind that packets to different peers shouldn't
> be blocked by one blocked peer. Any flow controlling or dropping of the packets
> needs to be done on a per-port basis.

Until we use a big hammer and reset the LDC channel of that peer, we
_absolutely_ should not reorder traffic and send to non-stuck peers.

A networking stack should avoid packet reordering in all cases when it
has the ability to do so, and sending packets which came in later to
unstuck peers when there are older packets still pending to the stuck
peer violates that requirement.
