From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mv643xx_eth: fix SMI bus access timeouts
Date: Sat, 1 Nov 2008 06:53:38 +0100
Message-ID: <20081101055338.GC13348@xi.wantstofly.org>
References: <20081101053220.GA13348@xi.wantstofly.org> <ada63n8xaik.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:55079 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbYKAFxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2008 01:53:40 -0400
Content-Disposition: inline
In-Reply-To: <ada63n8xaik.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2008 at 10:47:47PM -0700, Roland Dreier wrote:

> > If wait_event_timeout() would return zero, mv643xx_eth would conclude
> > that the SMI access timed out, but this is not necessarily true --
> > wait_event_timeout() can also return zero in the case where the SMI
> > completion interrupt did happen in time but where it took longer than
> > the requested timeout for the process performing the SMI access to be
> > scheduled again.  This would lead to occasional SMI access timeouts
> > when the system would be under heavy load.
> 
> Would it make more sense to fix this in the wait_event_timeout() code
> itself a la bb10ed09 ("sched: fix wait_for_completion_timeout() spurious
> failure under heavy load")?

Well, wait_event_timeout() does (or did, before that commit) exactly
what its docbook comment says it does:

	 * The function returns 0 if the @timeout elapsed, and the remaining
	 * jiffies if the condition evaluated to true before the timeout elapsed.

Making it return 1 jiffy seems a bit hacky.  Why not go all the way
and just make it return 0 or 1 in all cases and audit all the callers
(and update the docbook)?
