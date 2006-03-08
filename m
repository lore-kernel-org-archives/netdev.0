From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 1/4] net: percpufy frequently used vars -- add percpu_counter_mod_bh
Date: Wed, 8 Mar 2006 13:07:26 -0800
Message-ID: <20060308210726.GD4493@localhost.localdomain>
References: <20060308015808.GA9062@localhost.localdomain> <20060308015934.GB9062@localhost.localdomain> <20060307181301.4dd6aa96.akpm@osdl.org> <20060308202656.GA4493@localhost.localdomain> <20060308203642.GZ5410@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751013AbWCHVGr@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060308203642.GZ5410@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 08, 2006 at 03:36:42PM -0500, Benjamin LaHaise wrote:
> On Wed, Mar 08, 2006 at 12:26:56PM -0800, Ravikiran G Thirumalai wrote:
> > +static inline void percpu_counter_mod_bh(struct percpu_counter *fbc, long amount)
> > +{
> > +	local_bh_disable();
> > +	fbc->count += amount;
> > +	local_bh_enable();
> > +}
> 
> Please use local_t instead, then you don't have to do the local_bh_disable() 
> and enable() and the whole thing collapses down into 1 instruction on x86.

But on non x86, local_bh_disable() is gonna be cheaper than a cli/atomic op no?
(Even if they were switched over to do local_irq_save() and
local_irq_restore() from atomic_t's that is).

And if we use local_t, we will add the overhead for the non bh 
percpu_counter_mod for non x86 arches.

Thanks,
Kiran
