From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 11 Sep 2008 11:51:32 +0000
Message-ID: <20080911115132.GA5765@ff.dom.local>
References: <20080821.005250.117238212.davem@davemloft.net> <20080911.033956.233317469.davem@davemloft.net> <20080911104531.GA21913@gondor.apana.org.au> <20080911.034955.111797743.davem@davemloft.net> <20080911110035.GA22065@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:63497 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbYIKLvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 07:51:39 -0400
Received: by yx-out-2324.google.com with SMTP id 8so101055yxm.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 04:51:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080911110035.GA22065@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 09:00:35PM +1000, Herbert Xu wrote:
> On Thu, Sep 11, 2008 at 03:49:55AM -0700, David Miller wrote:
> > 
> > Well some kind of check has to be there.
> > 
> > I _did_ remove it during my initial implementation, and that
> > turned into a reported performance regression.
> 
> I see.  How about looking at the queue that the head-of-qdisc
> packet maps to? That should be fairly cheap to compute.
> 

Very good point: "That can't be right"! But I'm not sure I got the
above idea: e.g. this new sch_multiq can have different packets
depending just on some unstopped tx_queue.

IMHO, the most reasonable test here is for all tx_queues of a qdisc
beeing stopped, but since this is quite heavy, probably we need an
additional qdisc flag for such an occasion.

Jarek P.
