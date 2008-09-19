From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] sched: only dequeue if packet can be queued to
	hardware queue.
Date: Fri, 19 Sep 2008 17:16:32 +0200
Message-ID: <20080919151632.GB2646@ami.dom.local>
References: <20080918063036.27934.91273.stgit@localhost.localdomain> <20080918194419.GA2982@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, kaber@trash.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:57215 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbYISPQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 11:16:17 -0400
Received: by gv-out-0910.google.com with SMTP id e6so22508gvc.37
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2008 08:16:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080918194419.GA2982@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2008 at 09:44:19PM +0200, Jarek Poplawski wrote:
> Alexander Duyck wrote, On 09/18/2008 08:43 AM:
> ...
> > ---
> > This patch changes the behavior of the sch->dequeue to only
> > dequeue a packet if the queue it is bound for is not currently
> > stopped.  This functionality is provided via a new op called
> > smart_dequeue.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> > ---

Alexander, I guess you've seen my last messages/patches in this thread
and noticed that this __netif_schedule() problem is present both in
this RFC patch and sch_multiq: if skb isn't dequeued because of inner
tx_queue stopped state check, there is missing __netif_schedule()
before exit from qdisc_run().

Jarek P.
