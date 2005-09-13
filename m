From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 9/11] net: dst_entry.refcount, use, lastuse to use alloc_percpu
Date: Tue, 13 Sep 2005 16:17:17 -0700
Message-ID: <20050913231717.GC6249@localhost.localdomain>
References: <20050913161708.GK3570@localhost.localdomain> <20050913.132442.53540386.davem@davemloft.net> <20050913220737.GA6249@localhost.localdomain> <20050913.151216.48124942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, dipankar@in.ibm.com,
	bharata@in.ibm.com, shai@scalex86.org, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932497AbVIMXR1@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050913.151216.48124942.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 13, 2005 at 03:12:16PM -0700, David S. Miller wrote:
> From: Ravikiran G Thirumalai <kiran@scalex86.org>
> Date: Tue, 13 Sep 2005 15:07:37 -0700
> ...
> But using bigrefs, no way.  We have enough trouble making the data
> structures small without adding bloat like that.  A busy server can
> have hundreds of thousands of dst cache entries active on it, and they
> chew up enough memory as is.
> 

But even 1 Million dst cache entries would be 16+4 MB additional for a 4 cpu 
box....is that too much?  The alloc_percpu reimplementation interleaves
objects on cache lines, unlike the existing implementation which pads per-cpu
objects to cache lines...

If you are referring to embedded routing devices,
would they use CONFIG_NUMA or CONFIG_SMP?? (bigrefs nicely fold back to
regular atomic_t s on UPs)

Thanks,
Kiran
