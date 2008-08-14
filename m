From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 14 Aug 2008 08:52:50 +0000
Message-ID: <20080814085250.GC12217@ff.dom.local>
References: <20080813102701.GD5367@ff.dom.local> <20080813104238.GA11374@gondor.apana.org.au> <20080813105052.GA6838@ff.dom.local> <20080813.151918.61294677.davem@davemloft.net> <20080814075907.GA6797@ff.dom.local> <20080814081632.GB32475@gondor.apana.org.au> <20080814083127.GA12217@ff.dom.local> <20080814083336.GA452@gondor.apana.org.au> <20080814084429.GB12217@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:20128 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbYHNIw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 04:52:56 -0400
Received: by fk-out-0910.google.com with SMTP id 18so363892fkq.5
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 01:52:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080814084429.GB12217@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2008 at 08:44:29AM +0000, Jarek Poplawski wrote:
> On Thu, Aug 14, 2008 at 06:33:36PM +1000, Herbert Xu wrote:
> > On Thu, Aug 14, 2008 at 08:31:27AM +0000, Jarek Poplawski wrote:
> > >
> > > I'm not sure of your point... This patch is only to fix my yesterday's
> > > doubt #1, and it doesn't introduce, I hope, any new live-lock
> > > vulnerabity. So, if you mean doubt #2, there is needed a separate
> > > patch, but I'm not sure there is a need to add a flag. I've thougt
> > > about a counter in a Qdisc for consecutive requeues with
> > > netif_schedule, so we could break after some limit. Of course, your
> > > idea could be simpler and better, but if I could only see some code...
> > 
> > What I mean is the extremely unlikely scenario of net_tx_action
> > always failing on trylock because dev_deactivate has grabbed the
> > lock to check whether net_tx_action has completed.
> 
> Of course! I got it myself after responding and re-reading, sorry. So,
> this is yet another doubt, but I still wonder why you don't attach
> any code... (I'm currently trying to re-think this.)

On the other hand... such a flag would be probably for one thing only.
And if we would have a "netif_scheduled_without_xmitting" counter this
could probably make 2 in 1?

Jarek P.
