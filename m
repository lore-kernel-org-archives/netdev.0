From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 9/11] net: dst_entry.refcount, use, lastuse to use
	alloc_percpu
Date: Wed, 14 Sep 2005 17:21:02 +1000
Message-ID: <1126682462.7896.103.camel@localhost.localdomain>
References: <20050913220737.GA6249@localhost.localdomain>
	 <20050913.151216.48124942.davem@davemloft.net>
	 <20050913231717.GC6249@localhost.localdomain>
	 <20050913.162748.86496945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kiran@scalex86.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	dipankar@in.ibm.com, bharata@in.ibm.com, shai@scalex86.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965060AbVINHVF@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050913.162748.86496945.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2005-09-13 at 16:27 -0700, David S. Miller wrote:
> From: Ravikiran G Thirumalai <kiran@scalex86.org>
> Date: Tue, 13 Sep 2005 16:17:17 -0700
> 
> > But even 1 Million dst cache entries would be 16+4 MB additional for
> > a 4 cpu box....is that too much?
> 
> Absolutely.
> 
> Per-cpu counters are great for things like single instance
> statistics et al.  But once you start doing them per-object
> that's out of control bloat as far as I'm concerned.

This is why my original per-cpu allocator patch was damn slow, and
GFP_KERNEL only.  I wasn't convinced that high-churn objects are a good
fit for spreading across cpus.

I thought that net devices and modules (which uses a primitive
hard-coded "bigref" currently) were a fair uses for bigrefs, though I'd
like to see some stats.

Cheers,
Rusty.
-- 
A bad analogy is like a leaky screwdriver -- Richard Braakman
