From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/4] net: percpufy frequently used vars -- add
 percpu_counter_mod_bh
Date: Wed, 8 Mar 2006 15:43:21 -0800
Message-ID: <20060308154321.0e779111.akpm@osdl.org>
References: <20060308015808.GA9062@localhost.localdomain>
	<20060308015934.GB9062@localhost.localdomain>
	<20060307181301.4dd6aa96.akpm@osdl.org>
	<20060308202656.GA4493@localhost.localdomain>
	<20060308203642.GZ5410@kvack.org>
	<20060308210726.GD4493@localhost.localdomain>
	<20060308211733.GA5410@kvack.org>
	<20060308222528.GE4493@localhost.localdomain>
	<20060308224140.GC5410@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kiran@scalex86.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932078AbWCHXpW@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20060308224140.GC5410@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise <bcrl@kvack.org> wrote:
>
> On Wed, Mar 08, 2006 at 02:25:28PM -0800, Ravikiran G Thirumalai wrote:
> > Then, for the batched percpu_counters, we could gain by using local_t only for 
> > the UP case. But we will have to have a new local_long_t implementation 
> > for that.  Do you think just one use case of local_long_t warrants for a new
> > set of apis?
> 
> I think it may make more sense to simply convert local_t into a long, given 
> that most of the users will be things like stats counters.
> 

Yes, I agree that making local_t signed would be better.  It's consistent
with atomic_t, atomic64_t and atomic_long_t and it's a bit more flexible.

Perhaps.  A lot of applications would just be upcounters for statistics,
where unsigned is desired.  But I think the consistency argument wins out.
