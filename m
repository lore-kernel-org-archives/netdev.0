From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Thu, 17 May 2012 22:04:04 +0200
Message-ID: <20120517200404.GO14498@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu> <20120517.155503.2294382162578627387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2341 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932347Ab2EQUEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 16:04:08 -0400
Content-Disposition: inline
In-Reply-To: <20120517.155503.2294382162578627387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, May 17, 2012 at 03:55:03PM -0400, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 17 May 2012 17:01:57 +0200
> 
> >>From 6da6a21798d0156e647a993c31782eec739fa5df Mon Sep 17 00:00:00 2001
> > From: Willy Tarreau <w@1wt.eu>
> > Date: Thu, 17 May 2012 16:48:56 +0200
> > Subject: [PATCH] tcp: force push data out when buffers are missing
> > 
> > Commit 2f533844242 (tcp: allow splice() to build full TSO packets)
> > significantly improved splice() performance for some workloads but
> > caused stalls when pipe buffers were larger than socket buffers.
> > 
> > The issue seems to happen when no data can be copied at all due to
> > lack of buffers, which results in pending data never being pushed.
> > 
> > This change checks if all pending data has been pushed or not and
> > pushes them when waiting for send buffers.
> 
> Eric, please indicate whether we need Willy's patch here.
> 
> I want to propagate this fix as fast as possible if so.

I think you should hold off for now, because it's possible that my patch
hides another issue instead of fixing it.

I'm having the same stall issue again since I applied Eric's build_skb
patch, but not for all data sizes. So if the same issue is still there,
it's possible that we're playing hide-and-seek with it. That's rather
strange.

Thanks,
Willy
