From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] netfilter: Pass socket pointer down through okfn().
Date: Tue, 07 Apr 2015 15:18:07 -0400 (EDT)
Message-ID: <20150407.151807.1133352536485779137.davem@davemloft.net>
References: <20150407153533.GA3979@salvia>
	<20150407.120122.1683603489877737371.davem@davemloft.net>
	<1428433000.1370458.250399053.27D6D503@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428433000.1370458.250399053.27D6D503@webmail.messagingengine.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 07 Apr 2015 20:56:40 +0200

> This idea would imply to e.g. rename nf_hook_state into something not
> associated with netfilter. Otherwise I don't see any dependencies on
> netfilter.
> 
> I like the patches as-is and if not necessary we don't need to do this.

It's going to be NULL if netfilter didn't run because we only instantiate
the on-stack state when it's actually needed and we're going to call
down into netfilter.

Instantiating it unconditionally is not an option, because unless
netfilter runs setting up that structure is a complete waste of work.

Then we have strange semantics where this state thing is NULL,
depending upon whether netfilter was invoked or not.
