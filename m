From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Tue, 25 Sep 2007 19:28:11 -0700 (PDT)
Message-ID: <20070925.192811.08341847.davem@davemloft.net>
References: <20070919.090937.32177545.davem@davemloft.net>
	<1190255605.4818.25.camel@localhost>
	<1190256183.4818.28.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51193
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754015AbXIZC2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 22:28:11 -0400
In-Reply-To: <1190256183.4818.28.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 19 Sep 2007 22:43:03 -0400

> [NET_SCHED] explict hold dev tx lock
> 
> For N cpus, with full throttle traffic on all N CPUs, funneling traffic
> to the same ethernet device, the devices queue lock is contended by all
> N CPUs constantly. The TX lock is only contended by a max of 2 CPUS.
> In the current mode of operation, after all the work of entering the
> dequeue region, we may endup aborting the path if we are unable to get
> the tx lock and go back to contend for the queue lock. As N goes up,
> this gets worse.
> 
> The changes in this patch result in a small increase in performance
> with a 4CPU (2xdual-core) with no irq binding. Both e1000 and tg3
> showed similar behavior;
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

I've applied this to net-2.6.24, although I want to study more deeply
the implications of this change myself at some point :)
