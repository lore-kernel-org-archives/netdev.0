From: Matt Mackall <mpm@selenic.com>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 14:09:13 -0600
Message-ID: <20071123200913.GE19691@waste.org>
References: <20071123105518.GA22062@2ka.mipt.ru> <20071123170756.GV19691@waste.org> <20071123175757.GA23991@2ka.mipt.ru> <20071123184851.GA14415@2ka.mipt.ru> <20071123185101.GA17582@2ka.mipt.ru> <20071123185906.GA23710@2ka.mipt.ru> <20071123191120.GA19691@waste.org> <20071123193222.GA22168@2ka.mipt.ru> <20071123194139.GC19691@waste.org> <20071123195410.GA11401@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:34945 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757086AbXKWUQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 15:16:38 -0500
Content-Disposition: inline
In-Reply-To: <20071123195410.GA11401@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 10:54:11PM +0300, Evgeniy Polyakov wrote:
> On Fri, Nov 23, 2007 at 01:41:39PM -0600, Matt Mackall (mpm@selenic.com) wrote:
> > Here's another thought: move all this logic into the networking core,
> > unify it with current softirq zapper, then allow it to be called from
> > various other places (like atomic allocators). Then it'll all be in
> > central maintained place with more users.
> 
> This can be done quite easily - put a check into __kfree_skb() if
> netpoll is compiled-in and we are in hardirq context, then put skb
> into softirq freeing queue. Then zap_completion_queue() can free
> anything without ever knowing about nature of the packet, since this
> will be checked in __kfree_skb() anyway.

What I had in mind was moving the whole zap_completion_queue concept
into net/core/skbuff. So that netpoll (and, say, atomic kmalloc) can
simply call something like "clean_completion_queue".

-- 
Mathematics is the supreme nostalgia of our time.
