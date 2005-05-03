From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Tue, 3 May 2005 19:07:57 +1000
Message-ID: <20050503090757.GA29509@gondor.apana.org.au>
References: <E1DRFqC-00028H-Qi@tigger> <E1DRGWv-0003aa-00@gondolin.me.apana.org.au> <20050429093521.274adf9a.davem@davemloft.net> <20050429214336.04b40b3f.vsu@altlinux.ru> <4276238E.4060606@wetlettuce.com> <20050502212819.GA16177@gondor.apana.org.au> <57556.192.102.214.6.1115108726.squirrel@webmail.wetlettuce.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vsu@altlinux.ru, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Broadbent <markb@wetlettuce.com>
Content-Disposition: inline
In-Reply-To: <57556.192.102.214.6.1115108726.squirrel@webmail.wetlettuce.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 03, 2005 at 09:25:26AM +0100, Mark Broadbent wrote:
>
> >> See Documentation/spin-locking.txt line 137, this states that
> >> spin_[un]lock() should not be used in IRQ handlers.
> 
> "If you have a case where you have to protect a data structure across
> several CPU's and you want to use spinlocks you can potentially use
> cheaper versions of the spinlocks. IFF you know that the spinlocks are
> never used in interrupt handlers, you can use the non-irq versions:
> 
> 	spin_lock(&lock);
> 	...
> 	spin_unlock(&lock);
> "

Yes this isn't very clear.

What it's trying to say that if you're in a softirq/user context
and the spin lock may be taken in an IRQ context elsewhere then
you must use the IRQ-disabling version.

However, if you're in the IRQ context yourself, and yours is the
only IRQ context that takes that spin lock, then you may use the
straight spin_lock version.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
