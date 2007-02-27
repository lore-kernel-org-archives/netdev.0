From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Handle disabled preemption in gfp_any()
Date: Tue, 27 Feb 2007 09:56:57 -0800 (PST)
Message-ID: <20070227.095657.106265863.davem@davemloft.net>
References: <45E46EE3.9040802@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45403
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751734AbXB0R46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 12:56:58 -0500
In-Reply-To: <45E46EE3.9040802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 27 Feb 2007 18:48:19 +0100

> [NET]: Handle disabled preemption in gfp_any()
> 
> ctnetlink uses netlink_unicast from an atomic_notifier_chain
> (which is called within a RCU read side critical section)
> without holding further locks. netlink_unicast calls netlink_trim
> with the result of gfp_any() for the gfp flags, which are passed
> down to pskb_expand_header. gfp_any() only checks for softirq
> context and returns GFP_KERNEL, resulting in this warning:
> 
> BUG: sleeping function called from invalid context at mm/slab.c:3032
> in_atomic():1, irqs_disabled():0
> no locks held by rmmod/7010.

Applied, good catch Patrick.
