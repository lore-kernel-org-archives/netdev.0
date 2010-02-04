From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Net / pktgen: Fix freezing problem
Date: Thu, 4 Feb 2010 14:12:39 -0800
Message-ID: <20100204141239.aa94e75c.akpm@linux-foundation.org>
References: <201002042250.58944.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Ciprian Dorin Craciun <ciprian.craciun@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49043 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752365Ab0BDWNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 17:13:49 -0500
In-Reply-To: <201002042250.58944.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Feb 2010 22:50:58 +0100 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> From: Rafael J. Wysocki <rjw@sisk.pl>
> Subject: Net / pktgen: Fix freezing problem
> 
> Add missing try_to_freeze() to one of the pktgen_thread_worker() code
> paths so that it doesn't block suspend/hibernation.
> 
> Fixes http://bugzilla.kernel.org/show_bug.cgi?id=15006
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Reported-and-tested-by: Ciprian Dorin Craciun <ciprian.craciun@gmail.com>
> ---
>  net/core/pktgen.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> Index: linux-2.6/net/core/pktgen.c
> ===================================================================
> --- linux-2.6.orig/net/core/pktgen.c
> +++ linux-2.6/net/core/pktgen.c
> @@ -3524,6 +3524,7 @@ static int pktgen_thread_worker(void *ar
>  			wait_event_interruptible_timeout(t->queue,
>  							 t->control != 0,
>  							 HZ/10);
> +			try_to_freeze();
>  			continue;
>  		}
>  

Also needed in -stable, IMO.
