From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Thu, 24 Nov 2005 16:29:24 +0100
Message-ID: <20051124152924.GB5921@wotan.suse.de>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com> <4384E7F2.2030508@pobox.com> <20051123223007.GA5921@wotan.suse.de> <20051124001700.GC14246@kvack.org> <20051124065037.GZ20775@brahms.suse.de> <4385DB32.7010605@argo.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Benjamin LaHaise <bcrl@kvack.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Grover <andrew.grover@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932102AbVKXP33@vger.kernel.org>
To: Avi Kivity <avi@argo.co.il>
Content-Disposition: inline
In-Reply-To: <4385DB32.7010605@argo.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 24, 2005 at 05:24:34PM +0200, Avi Kivity wrote:
> Andi Kleen wrote:
> 
> >>Don't forget that there are benefits of not polluting the cache with the 
> >>traffic for the incoming skbs.
> >>   
> >>
> >
> >Is that a general benefit outside benchmarks? I would expect
> >most real programs to actually do something with the data
> >- and that usually involves needing it in cache.
> >
> > 
> >
> As an example, an NFS server reads some data pages using iSCSI and sends 
> them using NFS/TCP (or vice versa).

For TX this can be done zero copy using a sendfile like setup.

For RX it may help - but my point was that most applications
are not structured in this simple way.

> >>In the I/O AT case it might make sense to do a few prefetch()es of the 
> >>userland data on the return-to-userspace code path.  
> >>   
> >>
> >
> >Some prefetches for user space might be a good idea yes
> >
> > 
> >
> As long as they can be turned off. Not all usespace applications want to 
> touch the data immediately.

Perhaps.  And lots of others might. Of course the simple
network benchmarks don't so the number on them look good.

Just pointing out that it's not clear it will always be a big help.

-Andi
