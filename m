From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: Various optimizations
Date: Thu, 06 May 2010 22:07:59 -0700 (PDT)
Message-ID: <20100506.220759.25136752.davem@davemloft.net>
References: <1273136322.2357.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34295
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750987Ab0EGFHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:07:52 -0400
In-Reply-To: <1273136322.2357.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 May 2010 10:58:42 +0200

> Introduce ____napi_schedule() helper for callers in irq disabled
> contexts. rps_trigger_softirq() becomes a leaf function.
> 
> Use container_of() in process_backlog() instead of accessing per_cpu
> address.
> 
> Use a custom inlined version of __napi_complete() in process_backlog()
> to avoid one locked instruction :
> 
>  only current cpu owns and manipulates this napi,
>  and NAPI_STATE_SCHED is the only possible flag set on backlog.
>  we can use a plain write instead of clear_bit(),
>  and we dont need an smp_mb() memory barrier, since RPS is on,
>  backlog is protected by a spinlock.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks great, applied, thanks Eric.
