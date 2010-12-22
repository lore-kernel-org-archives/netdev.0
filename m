From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v5] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 18:13:07 +0100
Message-ID: <20101222171307.GA25611@elte.hu>
References: <1293037246.9820.236.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	eric.dumazet@gmail.com, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org,
	eparis@parisplace.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1293037246.9820.236.camel@dan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Dan Rosenberg <drosenberg@vsecurity.com> wrote:

> +	case 'K':
> +		/*
> +		 * %pK cannot be used in IRQ context because its test
> +		 * for CAP_SYSLOG would be meaningless.
> +		 */
> +		if (in_irq() || in_serving_softirq() || in_nmi())
> +			WARN_ONCE(1, "%%pK used in interrupt context.\n");

Hm, that bit looks possibly broken - some useful warning in irq context could print 
a pointer into the syslog and this would generate a second warning? That probably 
would crash as it recurses back into the printk code?

Instead a warning could be inserted into the generated output instead, for example 
'pK-error' (carefully staying within pointer length limits).

Also, it would be nice to see a couple of actual %pK usage sites submitted as well - 
instead of this pure infrastructure patch.

	Ingo
