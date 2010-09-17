From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: linux-next: build failure after merge of the rcu tree
Date: Fri, 17 Sep 2010 16:17:41 -0700
Message-ID: <20100917231741.GB3060@linux.vnet.ibm.com>
References: <20100917124238.aa0596cb.sfr@canb.auug.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100917124238.aa0596cb.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 17, 2010 at 12:42:38PM +1000, Stephen Rothwell wrote:
> Hi Paul,
> 
> After merging the rcu tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> net/core/dev.c: In function 'netdev_run_todo':
> net/core/dev.c:5294: error: dereferencing pointer to incomplete type
> net/core/dev.c:5294: warning: type defaults to 'int' in declaration of '_________p1'
> net/core/dev.c:5294: error: dereferencing pointer to incomplete type
> net/core/dev.c:5294: warning: type defaults to 'int' in declaration of 'type name'
> net/core/dev.c:5294: error: dereferencing pointer to incomplete type
> net/core/dev.c:5294: warning: type defaults to 'int' in declaration of 'type name'
> net/core/dev.c:5294: warning: comparison of distinct pointer types lacks a cast
> net/core/dev.c:5294: error: dereferencing pointer to incomplete type
> net/core/dev.c:5294: warning: type defaults to 'int' in declaration of 'type name'
> 
> Caused by commit ca5ecddfa8fcbd948c95530e7e817cee9fb43a3d ("rcu: define
> __rcu address space modifier for sparse") interacting with commit
> 95ae6b228f814fc0528d0506ee9f18ac333d6851 ("ipv4: ip_ptr cleanups") from
> the net tree.
> 
> rcu_dereference_raw() now needs to know the type of the object its
> argument points to.  I added the following merge fix (which could be
> applied to the net tree anyway).
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 17 Sep 2010 12:36:36 +1000
> Subject: [PATCH] net: include inetdevice.h for rcu_dereference_raw api change
> 
> rcu_dereference_raw() now needs to know the type of its argument.

Good catch, thank you!!!

							Thanx, Paul

> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  net/core/dev.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index c6d837a..cadd28c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -129,6 +129,7 @@
>  #include <linux/random.h>
>  #include <trace/events/napi.h>
>  #include <linux/pci.h>
> +#include <linux/inetdevice.h>
> 
>  #include "net-sysfs.h"
> 
> -- 
> 1.7.1
> 
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> http://www.canb.auug.org.au/~sfr/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
