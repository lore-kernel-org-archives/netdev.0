From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: link error : 2.6.21-rc6-mm1 for s390
Date: Tue, 10 Apr 2007 23:39:19 -0700
Message-ID: <20070410233919.0fa4894e.akpm@linux-foundation.org>
References: <20070410182937.8169c672.akpm@linux-foundation.org>
	<20070410.183629.57444787.davem@davemloft.net>
	<20070410184738.dc1c5943.akpm@linux-foundation.org>
	<20070410.221101.110908614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mathieu.desnoyers@polymtl.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@linux-foundation.org,
	heiko.carstens@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:33636 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576AbXDKGjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 02:39:54 -0400
In-Reply-To: <20070410.221101.110908614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Apr 2007 22:11:01 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> diff --git a/arch/s390/lib/Makefile b/arch/s390/lib/Makefile
> index 7a44fed..59aea65 100644
> --- a/arch/s390/lib/Makefile
> +++ b/arch/s390/lib/Makefile
> @@ -5,6 +5,6 @@
>  EXTRA_AFLAGS := -traditional
>  
>  lib-y += delay.o string.o uaccess_std.o uaccess_pt.o qrnnd.o
> -lib-$(CONFIG_32BIT) += div64.o
> +obj-$(CONFIG_32BIT) += div64.o
>  lib-$(CONFIG_64BIT) += uaccess_mvcos.o
>  lib-$(CONFIG_SMP) += spinlock.o
> diff --git a/arch/s390/lib/div64.c b/arch/s390/lib/div64.c
> index 0481f34..a5f8300 100644
> --- a/arch/s390/lib/div64.c
> +++ b/arch/s390/lib/div64.c
> @@ -147,5 +147,3 @@ uint32_t __div64_32(uint64_t *n, uint32_t base)
>  }
>  
>  #endif /* MARCH_G5 */
> -
> -EXPORT_SYMBOL(__div64_32);
> diff --git a/lib/div64.c b/lib/div64.c
> index 74f0c8c..b71cf93 100644
> --- a/lib/div64.c
> +++ b/lib/div64.c
> @@ -23,7 +23,7 @@
>  /* Not needed on 64bit architectures */
>  #if BITS_PER_LONG == 32
>  
> -uint32_t __div64_32(uint64_t *n, uint32_t base)
> +uint32_t __attribute__((weak)) __div64_32(uint64_t *n, uint32_t base)
>  {
>  	uint64_t rem = *n;
>  	uint64_t b = base;

I think this means that if CONFIG_32BIT=y, s390 networking gets the whizzy
assembly version and if CONFIG_32BIT=n, it gets to use the generic version.

Possibly the whizzy version could be used if CONFIG_32BIT=n, too.  But
I'd let the s390 people worry about that ;)
