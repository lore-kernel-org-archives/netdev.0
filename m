From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] via-velocity: fix netif_receive_skb use in irq
 disabled section.
Date: Thu, 28 Nov 2013 18:45:29 -0500 (EST)
Message-ID: <20131128.184529.1997166326512828518.davem@davemloft.net>
References: <20131125234058.GA12566@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aaschmidt1@gmail.com, michele@acksyn.org,
	jamie@audible.transient.net, Julia.Lawall@lip6.fr
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab3K1Xpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:45:31 -0500
In-Reply-To: <20131125234058.GA12566@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 26 Nov 2013 00:40:58 +0100

> 2fdac010bdcf10a30711b6924612dfc40daf19b8 ("via-velocity.c: update napi
> implementation") overlooked an irq disabling spinlock when the Rx part
> of the NAPI poll handler was converted from netif_rx to netif_receive_skb.
> 
> NAPI Rx processing can be taken out of the locked section with a pair of
> napi_{disable / enable} since it only races with the MTU change function.
> 
> An heavier rework of the NAPI locking would be able to perform NAPI Tx
> before Rx where I simply removed one of velocity_tx_srv calls.
> 
> References: https://bugzilla.redhat.com/show_bug.cgi?id=1022733
> Fixes: 2fdac010bdcf (via-velocity.c: update napi implementation)
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Alex A. Schmidt <aaschmidt1@gmail.com>

Applied and queued up for -stable, thanks.

Just a note that we usually recommend to people to do TX processing
before RX in NAPI, because the TX work can liberate packets and make
them available to RX reclaim.  But that would be quite hard with the
approach you took to fix this bug simply.
