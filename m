From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Hitting slab BUG with bridging/cxgb3 on 2.6.31-rc2
Date: Wed, 08 Jul 2009 22:38:23 -0700
Message-ID: <adaab3eza9c.fsf@cisco.com>
References: <adaeisq23rq.fsf@cisco.com> <adaljmyzof4.fsf@cisco.com>
	<4A554A1D.3070703@chelsio.com> <adaeisqzawa.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:26600 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbZGIFiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 01:38:25 -0400
In-Reply-To: <adaeisqzawa.fsf@cisco.com> (Roland Dreier's message of "Wed, 08
	Jul 2009 22:24:37 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > Yep, reverting that makes things work solid.  I don't see an obvious
 > problem with that patch... seems the only places that free TX skbs are
 > the xmit routine itself, and in sge_timer_tx() where it's protected by
 > doing __netif_tx_lock().

Looking a little deeper -- it seems that at least the msix interrupt
routines do look at txq stuff without taking the tx_lock, and possibly
wake the tx queue racily maybe....

Oh well, I'll let you stare at it a little now...

 - R.
