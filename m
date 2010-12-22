From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH v5] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 12:17:59 -0500
Message-ID: <1293038279.9820.250.camel@dan>
References: <1293037246.9820.236.camel@dan> <20101222171307.GA25611@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	eric.dumazet@gmail.com, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org,
	eparis@parisplace.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101222171307.GA25611@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-12-22 at 18:13 +0100, Ingo Molnar wrote:
> * Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> 
> > +	case 'K':
> > +		/*
> > +		 * %pK cannot be used in IRQ context because its test
> > +		 * for CAP_SYSLOG would be meaningless.
> > +		 */
> > +		if (in_irq() || in_serving_softirq() || in_nmi())
> > +			WARN_ONCE(1, "%%pK used in interrupt context.\n");
> 
> Hm, that bit looks possibly broken - some useful warning in irq context could print 
> a pointer into the syslog and this would generate a second warning? That probably 
> would crash as it recurses back into the printk code?
> 

The double "%%" acts as an escape and simply prints "%" rather than
treating it as a format specifier.

> Instead a warning could be inserted into the generated output instead, for example 
> 'pK-error' (carefully staying within pointer length limits).
> 
> Also, it would be nice to see a couple of actual %pK usage sites submitted as well - 
> instead of this pure infrastructure patch.
> 

I did this separately so that any arguments about individual usage
didn't sink the whole ship.  Don't worry, you'll get your usage sites
very soon. :)

-Dan
