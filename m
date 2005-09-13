From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 9/11] net: dst_entry.refcount, use, lastuse to use alloc_percpu
Date: Tue, 13 Sep 2005 15:07:37 -0700
Message-ID: <20050913220737.GA6249@localhost.localdomain>
References: <20050913155112.GB3570@localhost.localdomain> <20050913161708.GK3570@localhost.localdomain> <20050913.132442.53540386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, dipankar@in.ibm.com,
	bharata@in.ibm.com, shai@scalex86.org, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932522AbVIMWHx@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050913.132442.53540386.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 13, 2005 at 01:24:42PM -0700, David S. Miller wrote:
> 
> There is no way in the world this enormous amount of NUMA
> complexity is being added to the destination cache layer.

Agreed the dst changes are ugly; that can be worked on.  But the 
cacheline bouncing problem on the atomic_t dst_entry refcounter has been 
around for quite a while -- even on SMPs, not just NUMA.  We need a solution 
for that.  I thought you were against the dst_entry bloat caused by the 
previous version of the dst patch.  alloc_percpu takes that away.  You had
concerns about workloads with low route locality. Unfortunately we don't have
access to infrastructure setup for such tests :( 

As for the ugliness, would something on the lines of net_device refcounter 
patch in the series above be acceptable?

Thanks,
Kiran
