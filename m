From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] kill 8139too kernel thread (sorta)
Date: Tue, 1 Nov 2005 08:11:43 +1100
Message-ID: <20051031211143.GA6409@gondor.apana.org.au>
References: <20051031130255.GA26626@havoc.gtf.org> <E1EWgcG-0001dZ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932498AbVJaVLz@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <E1EWgcG-0001dZ-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2005 at 07:50:52AM +1100, Herbert Xu wrote:
> 
> However, in this case it's much easier than that.  Simply change
> rtl8139_thread to do
> 
> 	rtnl_lock();
> 	if (tp->time_to_die == 0) {
> 		rtl8139_thread_iter(dev, tp, tp->mmio_addr);
> 		schedule_delayed_work(&tp->thread, next_tick);
> 	}
> 	rtnl_unlock();

Actually this is no good either.  The reason is that rtl8139_stop_thread
never relinquinshes the RTNL so it has no way of waiting for this to
complete.

So I suppose we will have to use cancel_rearming_delayed_workqueue or
create an rtl-specific semaphore for this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
