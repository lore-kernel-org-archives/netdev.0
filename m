From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 9/11] net: dst_entry.refcount, use, lastuse to use
 alloc_percpu
Date: Tue, 13 Sep 2005 15:12:16 -0700 (PDT)
Message-ID: <20050913.151216.48124942.davem@davemloft.net>
References: <20050913161708.GK3570@localhost.localdomain>
	<20050913.132442.53540386.davem@davemloft.net>
	<20050913220737.GA6249@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, dipankar@in.ibm.com,
	bharata@in.ibm.com, shai@scalex86.org, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964785AbVIMWMb@vger.kernel.org>
To: kiran@scalex86.org
In-Reply-To: <20050913220737.GA6249@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ravikiran G Thirumalai <kiran@scalex86.org>
Date: Tue, 13 Sep 2005 15:07:37 -0700

> Agreed the dst changes are ugly; that can be worked on.  But the
> cacheline bouncing problem on the atomic_t dst_entry refcounter has
> been around for quite a while -- even on SMPs, not just NUMA.  We
> need a solution for that.  I thought you were against the dst_entry
> bloat caused by the previous version of the dst patch.  alloc_percpu
> takes that away.  You had concerns about workloads with low route
> locality. Unfortunately we don't have access to infrastructure setup
> for such tests :(

You don't have two computers connected on a network?

All you need is that, load a bunch of routes into one system that
point to an IP address which you just force an ARP entry for (so it
just gets lost in the ether) and then generate a rDOS workload through
it from another machine using pktgen.

I'm fine with funny per-cpu memory allocation strategies, perhaps
(would have to see a patch doing _only_ that to be sure).

But using bigrefs, no way.  We have enough trouble making the data
structures small without adding bloat like that.  A busy server can
have hundreds of thousands of dst cache entries active on it, and they
chew up enough memory as is.
