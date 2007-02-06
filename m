From: David Miller <davem@davemloft.net>
Subject: Re: [patch 01/11] user of the jiffies rounding code: Networking
Date: Mon, 05 Feb 2007 18:01:11 -0800 (PST)
Message-ID: <20070205.180111.36663426.davem@davemloft.net>
References: <200702060031.l160VtQ3004618@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arjan@linux.intel.com, jgarzik@pobox.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33244
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965378AbXBFCBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 21:01:12 -0500
In-Reply-To: <200702060031.l160VtQ3004618@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 05 Feb 2007 16:30:52 -0800

> From: Arjan van de Ven <arjan@linux.intel.com>
> 
> This patch introduces users of the round_jiffies() function in the networking
> code.
> 
> These timers all were of the "about once a second" or "about once every X
> seconds" variety and several showed up in the "what wakes the cpu up" profiles
> that the tickless patches provide.  Some timers are highly dynamic based on
> network load; but even on low activity systems they still show up so the
> rounding is done only in cases of low activity, allowing higher frequency
> timers in the high activity case.
> 
> The various hardware watchdogs are an obvious case; they run every 2 seconds
> but aren't otherwise specific of exactly when they need to run.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I pulled in everything except the e1000 driver change, Jeff please
suck that in, thanks.

Arjan, btw:

> +	if (dst_gc_timer_expires > 4*HZ)
> +		mod_timer(&dst_gc_timer,
> +			round_jiffies(jiffies + dst_gc_timer_expires));
> +	else
> +		mod_timer(&dst_gc_timer, jiffies + dst_gc_timer_expires);
   ^^^^^^^^^^^^^

That line begins "TAB SPACE TAB", and lo' and behold GIT
catch this when I applied it :-)  I fixed it up by hand
and reapplied, so don't worry about this instance.

