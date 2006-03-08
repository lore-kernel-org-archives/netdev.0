From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 1/4] net: percpufy frequently used vars -- add percpu_counter_mod_bh
Date: Wed, 8 Mar 2006 16:17:33 -0500
Message-ID: <20060308211733.GA5410@kvack.org>
References: <20060308015808.GA9062@localhost.localdomain> <20060308015934.GB9062@localhost.localdomain> <20060307181301.4dd6aa96.akpm@osdl.org> <20060308202656.GA4493@localhost.localdomain> <20060308203642.GZ5410@kvack.org> <20060308210726.GD4493@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932274AbWCHVWz@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Content-Disposition: inline
In-Reply-To: <20060308210726.GD4493@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 08, 2006 at 01:07:26PM -0800, Ravikiran G Thirumalai wrote:
> But on non x86, local_bh_disable() is gonna be cheaper than a cli/atomic op no?
> (Even if they were switched over to do local_irq_save() and
> local_irq_restore() from atomic_t's that is).

It's still more expensive than local_t.

> And if we use local_t, we will add the overhead for the non bh 
> percpu_counter_mod for non x86 arches.

Last time I checked, all the major architectures had efficient local_t 
implementations.  Most of the RISC CPUs are able to do a load / store 
conditional implementation that is the same cost (since memory barriers 
tend to be explicite on powerpc).  So why not use it?

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
