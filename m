From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 14 Aug 2008 08:31:27 +0000
Message-ID: <20080814083127.GA12217@ff.dom.local>
References: <20080813102701.GD5367@ff.dom.local> <20080813104238.GA11374@gondor.apana.org.au> <20080813105052.GA6838@ff.dom.local> <20080813.151918.61294677.davem@davemloft.net> <20080814075907.GA6797@ff.dom.local> <20080814081632.GB32475@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:32523 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbYHNIbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 04:31:34 -0400
Received: by ik-out-1112.google.com with SMTP id c28so387130ika.5
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 01:31:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080814081632.GB32475@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2008 at 06:16:32PM +1000, Herbert Xu wrote:
> On Thu, Aug 14, 2008 at 07:59:07AM +0000, Jarek Poplawski wrote:
> > 
> > net: Change handling of the __QDISC_STATE_SCHED flag in net_tx_action().
> > 
> > Change handling of the __QDISC_STATE_SCHED flag in net_tx_action() to
> > enable proper control in dev_deactivate_queue(). Now, if this flag is
> > seen as unset under root_lock means a qdisc can't be netif_scheduled.
> > 
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Well this probably works in practice but at least on paper it
> is vulnerable to live-lock if the net_tx_action side always gets
> to the trylock stage and loses to the waiting side.
> 
> An aliveness flag would be the safest.

I'm not sure of your point... This patch is only to fix my yesterday's
doubt #1, and it doesn't introduce, I hope, any new live-lock
vulnerabity. So, if you mean doubt #2, there is needed a separate
patch, but I'm not sure there is a need to add a flag. I've thougt
about a counter in a Qdisc for consecutive requeues with
netif_schedule, so we could break after some limit. Of course, your
idea could be simpler and better, but if I could only see some code...

Cheers,
Jarek P.
