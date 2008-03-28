From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 20/21] forcedeth: fix locking bug with netconsole
Date: Fri, 28 Mar 2008 16:42:09 -0700
Message-ID: <20080328164209.e8b723d8.akpm@linux-foundation.org>
References: <200803282141.m2SLfUwU011858@imap1.linux-foundation.org>
	<20080328.154353.43255092.davem@davemloft.net>
	<47ED75CE.1080400@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mingo@elte.hu, aabdulla@nvidia.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35980 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756444AbYC1Xm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:42:29 -0400
In-Reply-To: <47ED75CE.1080400@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Mar 2008 18:48:46 -0400 Jeff Garzik <jeff@garzik.org> wrote:

> David Miller wrote:
> > From: akpm@linux-foundation.org
> > Date: Fri, 28 Mar 2008 14:41:30 -0700
> > 
> >> From: Ingo Molnar <mingo@elte.hu>
> >>
> >> While using netconsole on forcedeth, lockdep noticed the following locking
> >> bug:
> > 
> > Please do not mix device driver changes with core networking
> > changes.
> 
> FWIW my plan was to snip the net/* stuff and only apply the forcedeth 
> portion.
> 
> (leaving <whomever> to pick up the pieces, should they so desire)
> 

Just drop 'em completely I'd say.

otoh, drivers do seem a bit flakey in the netpoll-support area, so a bit of
extra debug wouldn't hurt.  But checking irqs_disabled() either side of a
udelay() was a bit paranoid ;)

