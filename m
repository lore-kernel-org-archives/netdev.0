From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]  allow CONFIG_NET=n on ppc64
Date: Wed, 29 Sep 2004 22:15:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929201524.GA14615@wotan.suse.de>
References: <20040929200158.GA16366@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Hering <olh@suse.de>
Content-Disposition: inline
In-Reply-To: <20040929200158.GA16366@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 10:01:58PM +0200, Olaf Hering wrote:
> 
> The attached minimal config does not compile on ppc64.
> I was able to boot the resulting binary with this patch.

I already fixed this some time ago, but the patch must have disappeared.

> diff -purNX /suse/olh/kernel/kernel_exclude.txt linux-2.6.9-rc2/arch/ppc64/kernel/misc.S linux-2.6.9-rc2.ppc64/arch/ppc64/kernel/misc.S
> --- linux-2.6.9-rc2/arch/ppc64/kernel/misc.S	2004-09-13 07:33:23.000000000 +0200
> +++ linux-2.6.9-rc2.ppc64/arch/ppc64/kernel/misc.S	2004-09-29 21:00:44.909074755 +0200
> @@ -703,7 +703,11 @@ _GLOBAL(sys_call_table32)
>  	.llong .compat_sys_statfs
>  	.llong .compat_sys_fstatfs		/* 100 */
>  	.llong .sys_ni_syscall		/* old ioperm syscall */
> +#ifdef CONFIG_NET
>  	.llong .compat_sys_socketcall
> +#else
> +	.llong .sys_ni_syscall		/* old ioperm syscall */
> +#endif

Right fix is to declare compat_sys_socketcall as as cond_syscall() 
in sys.c

-Andi
