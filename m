From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] net: don't use in_atomic() in gfp_any()
Date: Wed, 11 Feb 2009 14:02:59 -0800 (PST)
Message-ID: <20090211.140259.206413808.davem@davemloft.net>
References: <200902112127.n1BLRJeJ031575@imap1.linux-foundation.org>
	<200902120638.BFG12928.FFMOHJOVtOQLFS@I-love.SAKURA.ne.jp>
	<20090211134842.7fa73b6d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52938
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751013AbZBKWDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 17:03:05 -0500
In-Reply-To: <20090211134842.7fa73b6d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 11 Feb 2009 13:48:42 -0800

> Is gfp_any() supposed to be usable from hardirq context?
> 
> If so, we should use in_interrupt().
> 
> If not, we should use in_softirq(), and we'll then get might_sleep()
> warnings if anyone uses gfp_any() from hard irq context.

It never will be used in hardware IRQ context, at least
in the networking.

And all uses in the tree are.. networking :-)
