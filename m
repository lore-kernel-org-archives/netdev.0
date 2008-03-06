From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] Probably lockdep bug Re: circular locking, mirred,
	2.6.24.2
Date: Thu, 6 Mar 2008 09:41:57 +0000
Message-ID: <20080306094156.GA3954@ff.dom.local>
References: <20080305103935.M76165@visp.net.lb> <20080305135448.GA4636@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:15332 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760775AbYCFJkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 04:40:39 -0500
Received: by ug-out-1314.google.com with SMTP id z38so3734295ugc.16
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 01:40:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080305135448.GA4636@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2008 at 01:54:48PM +0000, Jarek Poplawski wrote:
> Hi,
> 
> dev->queue_lock is taken in a scenario like below: always after
> dev->ingress_lock and p->tcfc_lock, so just like on this last
> backtrace with info about held locks. But this report shows that
> lockdep for some reason forgot the history before dev->queue_lock,
> and recorded it again. It seems, even if there is something wrong
> with init lockdep shouldn't report it like this.

...Hmmm... On the other hand, despite misleading dependency chain on
this report, lockdep seems to be right: dev->queue_lock and
dev->ingress_lock are really taken in a different order from
qdisc_lock_tree() and while using act_mirred! Now I wonder why this
warning is so rare?

So, let's give a break to lockdep maintainers and linux-kernel, and
try to figure it out more in netdev...

Jarek P.
