From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit to upper layer
Date: Sat, 14 Mar 2009 02:53:40 +0100
Message-ID: <20090314015340.GM11935@one.firstfloor.org>
References: <65634d660903131358h765bef64y6a0f1b0db7400f6f@mail.gmail.com> <20090313.140217.143696945.davem@davemloft.net> <65634d660903131459m645eb468y3ad850a1fd56d447@mail.gmail.com> <20090313.151913.21135937.davem@davemloft.net> <65634d660903131724s49009177pdc11005aa76a4b56@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, yanmin_zhang@linux.intel.com,
	bhutchings@solarflare.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	shemminger@vyatta.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:34385 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765156AbZCNBxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 21:53:35 -0400
Content-Disposition: inline
In-Reply-To: <65634d660903131724s49009177pdc11005aa76a4b56@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, we are using a 10G NIC that supports multi-queue.  The number of
> RX queues supported is half the number of cores on our platform, so
> that is going to limit the parallelism.  With multi-queue turned on we

The standard wisdom is that you don't necessarily need to transmit
to each core, but rather to each shared mid or least level cache.
Once the data is cache hot (or cache near) distributing it further
in software is comparable cheap.

So this means you don't necessarily need as many queues as cores,
but more as many as big caches.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
