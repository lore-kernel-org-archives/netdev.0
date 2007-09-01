From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc4-mm1
Date: Fri, 31 Aug 2007 23:58:15 -0700
Message-ID: <20070831235815.a09c7865.akpm@linux-foundation.org>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
	<20070901155353.8a09db69.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47907 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751987AbXIAG7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 02:59:25 -0400
In-Reply-To: <20070901155353.8a09db69.kamezawa.hiroyu@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Sat, 1 Sep 2007 15:53:53 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I met 2 troubles while I compiled rc4-mm1 on x86/UP system,
> 
> One on pcnet32.c (patch is attaced below).
> One on crypto CONFIG.
> 
> == compile log ==
> drivers/net/pcnet32.c: In function 'pcnet32_netif_stop':
> drivers/net/pcnet32.c:445: warning: unused variable 'lp'
> drivers/net/pcnet32.c: In function 'pcnet32_netif_start':
> drivers/net/pcnet32.c:455: warning: unused variable 'lp'
> drivers/net/pcnet32.c: In function 'pcnet32_interrupt':
> drivers/net/pcnet32.c:2622: error: 'struct net_device' has no member named 'napi'

Only git-net touches pcnet32.c

> crypto/built-in.o: In function `update2':
> digest.c:(.text+0x94a): undefined reference to `crypto_km_types'
> digest.c:(.text+0x9bf): undefined reference to `crypto_km_types'
> 
> digest.c (CONFIG_CRYPTO) uses crypto/scatterwalk.c's object (CONFIG_CRYPTO_ALGAPI)
> I meet this when CONFIG_CRYPTO_ALGAPI=m. I need to make CONFIG_CRYPTO_ALGAPI=y.

cc herbert..

> Regards,
> -Kame.
> == cut from here ==
> 
>  tiny bug fix for pcnet32.c (maybe works well. please confirm.)
> 
>  Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  drivers/net/pcnet32.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: devel-2.6.23-rc4-mm1/drivers/net/pcnet32.c
> ===================================================================
> --- devel-2.6.23-rc4-mm1.orig/drivers/net/pcnet32.c
> +++ devel-2.6.23-rc4-mm1/drivers/net/pcnet32.c
> @@ -2619,7 +2619,7 @@ pcnet32_interrupt(int irq, void *dev_id)
>  			break;
>  		}
>  #else
> -		pcnet32_rx(dev, dev->napi.weight);
> +		pcnet32_rx(dev, lp->napi.weight);
>  		if (pcnet32_tx(dev)) {
>  			/* reset the chip to clear the error condition, then restart */
>  			lp->a.reset(ioaddr);

cc netdev, thanks.
