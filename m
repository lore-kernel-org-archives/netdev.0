From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v7] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 20:10:55 -0800
Message-ID: <1293077455.28077.6.camel@Joe-Laptop>
References: <1293069792.9820.342.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	eric.dumazet@gmail.com, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, mingo@elte.hu, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org,
	eparis@parisplace.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293069792.9820.342.camel@dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-12-22 at 21:03 -0500, Dan Rosenberg wrote:
> Add the %pK printk format specifier and
> the /proc/sys/kernel/kptr_restrict sysctl.

Another trivial style comment:

> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
[]
> +	case 'K':
> +		/*
> +		 * %pK cannot be used in IRQ context because its test
> +		 * for CAP_SYSLOG would be meaningless.
> +		 */
> +		if (in_irq() || in_serving_softirq() || in_nmi()) {
> +			if (spec.field_width == -1)
> +				spec.field_width = 2 * sizeof(void *);
> +			return string(buf, end, "pK-error", spec);
> +		}
> +
> +		else if ((kptr_restrict == 0) ||
> +			 (kptr_restrict == 1 &&
> +			  has_capability_noaudit(current, CAP_SYSLOG)))
> +			break;
> +

---

> +		if (spec.field_width == -1) {
> +			spec.field_width = 2 * sizeof(void *);
> +			spec.flags |= ZEROPAD;
> +		}
> +		return number(buf, end, 0, spec);

It'd be slightly smaller code to use:

 		   ptr = 0;
		   break;

and delete the if block and return number.

>  	}
>  	spec.flags |= SMALL;
>  	if (spec.field_width == -1) {
