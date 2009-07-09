From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Hitting slab BUG with bridging/cxgb3 on 2.6.31-rc2
Date: Wed, 08 Jul 2009 22:24:37 -0700
Message-ID: <adaeisqzawa.fsf@cisco.com>
References: <adaeisq23rq.fsf@cisco.com> <adaljmyzof4.fsf@cisco.com>
	<4A554A1D.3070703@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:35713 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbZGIFYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 01:24:38 -0400
In-Reply-To: <4A554A1D.3070703@chelsio.com> (Divy Le Ray's message of "Wed, 08
	Jul 2009 18:38:37 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > The cxgb3 patch that touches the data path since 2.6.30 is the LLTX removal:
 > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=c3a8c5b644118b5e2cfd0690b1dcea904a792c52

 > Would you mind reverting only this change only and see if the bug is
 > going away?

Yep, reverting that makes things work solid.  I don't see an obvious
problem with that patch... seems the only places that free TX skbs are
the xmit routine itself, and in sge_timer_tx() where it's protected by
doing __netif_tx_lock().

 - R.
