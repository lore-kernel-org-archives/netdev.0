From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 11:29:31 -0700 (PDT)
Message-ID: <20081007.112931.144606424.davem@davemloft.net>
References: <48EA8197.6080502@cosmosbay.com>
	<20081006.144002.56418911.davem@davemloft.net>
	<1223368290.26330.10.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, minyard@acm.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: a.p.zijlstra@chello.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753972AbYJGS34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 14:29:56 -0400
In-Reply-To: <1223368290.26330.10.camel@lappy.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 07 Oct 2008 10:31:30 +0200

> On Mon, 2008-10-06 at 14:40 -0700, David Miller wrote:
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Mon, 06 Oct 2008 23:22:31 +0200
> > 
> > > Me wondering what impact this synchronize_rcu() can have on mono-threaded
> > > VOIP applications using lot of UDP sockets. What is the maximum delay of
> > > this function ?
> > 
> > The cost is enormous, we really can't use it here.
> > 
> > I have a patch that did top-level socket destruction using RCU,
> > and that didn't use synchronize_rcu(), and that killed connection
> > rates by up to %20.
> 
> Did you ever figure out why you lost those 20% ?

Probably the RCU delay on a 128 cpu machine :-)

Also I bet batching the socket destruction eliminates all of
the cached local state we have in the cpu at the actual socket
destruction time.
