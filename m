From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 14 Aug 2008 08:44:29 +0000
Message-ID: <20080814084429.GB12217@ff.dom.local>
References: <20080813102701.GD5367@ff.dom.local> <20080813104238.GA11374@gondor.apana.org.au> <20080813105052.GA6838@ff.dom.local> <20080813.151918.61294677.davem@davemloft.net> <20080814075907.GA6797@ff.dom.local> <20080814081632.GB32475@gondor.apana.org.au> <20080814083127.GA12217@ff.dom.local> <20080814083336.GA452@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:64869 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbYHNIom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 04:44:42 -0400
Received: by fg-out-1718.google.com with SMTP id 19so319684fgg.17
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 01:44:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080814083336.GA452@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2008 at 06:33:36PM +1000, Herbert Xu wrote:
> On Thu, Aug 14, 2008 at 08:31:27AM +0000, Jarek Poplawski wrote:
> >
> > I'm not sure of your point... This patch is only to fix my yesterday's
> > doubt #1, and it doesn't introduce, I hope, any new live-lock
> > vulnerabity. So, if you mean doubt #2, there is needed a separate
> > patch, but I'm not sure there is a need to add a flag. I've thougt
> > about a counter in a Qdisc for consecutive requeues with
> > netif_schedule, so we could break after some limit. Of course, your
> > idea could be simpler and better, but if I could only see some code...
> 
> What I mean is the extremely unlikely scenario of net_tx_action
> always failing on trylock because dev_deactivate has grabbed the
> lock to check whether net_tx_action has completed.

Of course! I got it myself after responding and re-reading, sorry. So,
this is yet another doubt, but I still wonder why you don't attach
any code... (I'm currently trying to re-think this.)

Jarek P.
