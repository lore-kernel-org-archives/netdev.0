From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/2] drop_monitor: fix sleeping in invalid context
 warning
Date: Sat, 28 Apr 2012 08:11:13 +0200
Message-ID: <1335593473.2900.0.camel@edumazet-glaptop>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
	 <1335557509-32726-1-git-send-email-nhorman@tuxdriver.com>
	 <1335557509-32726-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54506 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab2D1GLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 02:11:17 -0400
Received: by wejx9 with SMTP id x9so837311wej.19
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 23:11:15 -0700 (PDT)
In-Reply-To: <1335557509-32726-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 16:11 -0400, Neil Horman wrote:
> Eric Dumazet pointed out this warning in the drop_monitor protocol to me:
> 

> It stems from holding a spinlock (trace_state_lock) while attempting to register
> or unregister tracepoint hooks, making in_atomic() true in this context, leading
> to the warning when the tracepoint calls might_sleep() while its taking a mutex.
> Since we only use the trace_state_lock to prevent trace protocol state races, as
> well as hardware stat list updates on an rcu write side, we can just convert the
> spinlock to a mutex to avoid this problem.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Miller <davem@davemloft.net>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Neil
