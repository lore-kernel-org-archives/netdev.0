From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Do less atomic count changes in dev_queue_xmit
Date: Mon, 6 Sep 2004 08:03:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040905220341.GA13217@gondor.apana.org.au>
References: <20040904135439.GA23934@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040904135439.GA23934@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Sep 04, 2004 at 01:54:39PM +0000, Andi Kleen wrote:
> 
> diff -u linux-2.6.8/net/core/dev.c-o linux-2.6.8/net/core/dev.c
> --- linux-2.6.8/net/core/dev.c-o	2004-09-04 13:10:47.000000000 +0000
> +++ linux-2.6.8/net/core/dev.c	2004-09-04 13:47:16.765722813 +0000
> @@ -1249,14 +1249,14 @@
>  	return 0;
>  }
>  
> -#define HARD_TX_LOCK_BH(dev, cpu) {			\
> +#define HARD_TX_LOCK(dev, cpu) {			\
>  	if ((dev->features & NETIF_F_LLTX) == 0) {	\
>  		spin_lock_bh(&dev->xmit_lock);		\

You can remove the _bh here as well.

> @@ -1358,12 +1361,11 @@
>  	   Either shot noqueue qdisc, it is even simpler 8)
>  	 */
>  	if (dev->flags & IFF_UP) {
> -		int cpu = get_cpu();
> +		int cpu = smp_processor_id(); /* ok because BHs are off */

Hmm this means that the loopback xmit function will now execute with
BH/preempt turned off.  Is this what we want?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
