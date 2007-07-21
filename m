From: David Miller <davem@davemloft.net>
Subject: Re: ~3 hours old git tree: Virtual device lo asks to queue packet!
Date: Fri, 20 Jul 2007 19:47:43 -0700 (PDT)
Message-ID: <20070720.194743.71090882.davem@davemloft.net>
References: <200707190819.53364.arekm@maven.pl>
	<469F2E14.9050200@trash.net>
	<469F38BE.4030401@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, arekm@maven.pl,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752458AbXGUCrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 22:47:43 -0400
In-Reply-To: <469F38BE.4030401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 19 Jul 2007 12:11:10 +0200

> The easiest fix would be to use egress_subqueue[1] in struct
> net_device, but I think that may cause warnings with newer gccs
> when using a constant index that is > 0. OTOH using constant
> indices doesn't seem to make much sense for the subqueue array.
> 
> Arkadiusz, does this patch fix the problem?

I've applied this, but long term we should either:

1) Make loopback_dev dynamically allocated just like every
   other netdev, so make loopback_init() a postcore_initcall()
   to make sure that is setup early enough.

   Then have to walk over the tree making everything able
   to handle the fact that it's a pointer.  Several data
   structures are compile time initialized to "&loopback_dev"
   for example, and therefore will have to be transformed into
   a run-time initialization.

2) Pick some arbitrary limit for the queues, and just have that
   many of them allocated in every netdev.

I like #2 because it allows us to get back the netdev_priv()
optimization.
