From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/7] atm: replace del_timer by del_timer_sync
Date: Wed, 26 Mar 2014 23:56:04 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403262344060.7710@ionos.tec.linutronix.de>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>   <1395869625-15209-3-git-send-email-Julia.Lawall@lip6.fr>  <1395871015.12610.254.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.02.1403262301171.31401@ionos.tec.linutronix.de>
 <1395872545.12610.262.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1395872545.12610.262.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 26 Mar 2014, Eric Dumazet wrote:

> On Wed, 2014-03-26 at 23:02 +0100, Thomas Gleixner wrote:
> 
> > That's why you need del_timer_sync() it waits for the timer handler to
> > complete and then removes it.
> 
> Interesting... So maybe some comment is stale ?
> 
> 
> diff --git a/kernel/timer.c b/kernel/timer.c
> index accfd241b9e5..c948fa2fc065 100644
> --- a/kernel/timer.c
> +++ b/kernel/timer.c
> @@ -1011,10 +1011,10 @@ EXPORT_SYMBOL(try_to_del_timer_sync);
>   * the timer it also makes sure the handler has finished executing on other
>   * CPUs.
>   *
> - * Synchronization rules: Callers must prevent restarting of the timer,
> - * otherwise this function is meaningless. It must not be called from

We still need to prevent restarting from some other site,
i.e. interrupt. It's fine if the timer handler itself restarts the
timer, as del_timer_sync() wait for the handler to finish and then
delete the timer.

I can't find the reason why it can't call add_timer_on(). We
lock/unlock the timer base in every try_to_del_timer_sync() loop so we
detect the base change.

Thanks,

	tglx
