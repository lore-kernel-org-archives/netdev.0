From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: in_atomic() misuse all over the place
Date: Sat, 31 Jan 2009 00:48:43 -0800 (PST)
Message-ID: <20090131.004843.127193545.davem@davemloft.net>
References: <20090130160316.7e53ef99.akpm@linux-foundation.org>
	<20090131055508.GD18453@one.firstfloor.org>
	<20090130214933.1b91ea3e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, roger.larsson@e-gatan.se,
	linux-kernel@vger.kernel.org, mingo@elte.hu, rml@tech9.net,
	pavel@ucw.cz, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750856AbZAaIsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 03:48:47 -0500
In-Reply-To: <20090130214933.1b91ea3e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 30 Jan 2009 21:49:33 -0800

> Hang on.  You said
> 
>   That's typically for softirq vs non softirq, which is important for
>   the network stack.
> 
> that's what in_softirq() does.
> 
> Now, if networking is indeed using in_atomic() to detect
> are-we-inside-a-spinlock then networking is buggy.
> 
> If networking is _not_ doing that then we can safely switch it to
> in_sortirq() or in_interrupt().  And this would reenable the bug
> detection which networking's use of in_atomic() accidentally
> suppressed.

I think this is a reasonable conclusion, looking at the
gfp_any() users.

Feel free to change it to use in_softirq() and see what
explodes in -mm.  Report to me your findings :-)
