From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 12 Aug 2008 10:38:17 +0000
Message-ID: <20080812103817.GA6794@ff.dom.local>
References: <20080812052048.GA4291@ff.dom.local> <20080811.224047.154563272.davem@davemloft.net> <20080812070005.GB5066@ff.dom.local> <20080812.011510.20845920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:18642 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbYHLKic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 06:38:32 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1308535fgg.17
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 03:38:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080812.011510.20845920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 01:15:10AM -0700, David Miller wrote:
...
> The synchronization object is the qdisc.  So we can't resample the
> qdisc after scheduling it, because then the qdisc attached to the
> netdev_queue can change and we'd be holding the root lock for
> the wrong qdisc object.

If you mean net_tx_action() this looks like we would get a root lock
of a current qdisc, just like seen in dev_queue_xmit() at the moment,
so I'm still looking for a clue, what could be wrong with this...

Jarek P.
