From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] netconsole broken by scheduler updates
Date: Thu, 26 May 2011 16:18:21 -0400 (EDT)
Message-ID: <20110526.161821.1324179861744722209.davem@davemloft.net>
References: <4DDE1B7D.7080707@free.fr>
	<1306403308.1200.44.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laurent.riffard@free.fr, netdev@vger.kernel.org
To: a.p.zijlstra@chello.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758419Ab1EZUSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 16:18:34 -0400
In-Reply-To: <1306403308.1200.44.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 26 May 2011 11:48:28 +0200

> Also, are you very _very_ sure that lockdep message is a false positive?

I suspect these warnings are entirely specific to using netconsole
with the forcedeth driver.

There is some really scary stuff in there, to say the least.

Just have a look at nv_do_nic_poll().  That's the first time I've
seen a networking driver use the {disable,enable}_irq_lockdep()
interfaces.

It's also using netif_tx_unlock_bh() in the "recovery" case which
in netpoll will cause a local_bh_enable() with cpu interrupts
disabled.  Which is not allowed.

Much of the forcedeth driver's locking seems suspect to me.
