From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] kill 8139too kernel thread (sorta)
Date: Sat, 5 Nov 2005 15:20:08 +1100
Message-ID: <20051105042008.GA25823@gondor.apana.org.au>
References: <20051031130255.GA26626@havoc.gtf.org> <E1EWgcG-0001dZ-00@gondolin.me.apana.org.au> <20051031211143.GA6409@gondor.apana.org.au> <436C2B47.3030505@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751159AbVKEEUU@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <436C2B47.3030505@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 04, 2005 at 10:47:19PM -0500, Jeff Garzik wrote:
> Here's a better version, that uses cancel_rearming_...

Yep it certainly solves the race condition.

> +	if (rtnl_shlock_nowait() == 0) {
>  		rtl8139_thread_iter (dev, tp, tp->mmio_addr);
>  		rtnl_unlock ();
>  	}
>  
> -	complete_and_exit (&tp->thr_exited, 0);
> +	schedule_delayed_work(&tp->thread, next_tick);

My only concern is the potential for starvation here should we fail
to obtain the RTNL.  Since any local user can hold the RTNL by issuing
rtnetlink requests, it is theoretically possible for the rtl8139 work
to be delayed indefinitely.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
