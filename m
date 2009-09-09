From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Wed, 9 Sep 2009 07:42:38 -0700
Message-ID: <20090909144238.GA6749@linux.vnet.ibm.com>
References: <4AA00400.1030005@gmail.com> <alpine.DEB.1.10.0909031731540.24199@V090114053VZO-1> <20090903231757.GP6761@linux.vnet.ibm.com> <alpine.DEB.1.10.0909041140040.9781@V090114053VZO-1> <20090904204335.GG6751@linux.vnet.ibm.com> <alpine.DEB.1.10.0909081555410.26382@V090114053VZO-1> <20090908222036.GM6753@linux.vnet.ibm.com> <alpine.DEB.1.10.0909081839090.7733@V090114053VZO-1> <20090908225937.GO6753@linux.vnet.ibm.com> <alpine.DEB.1.10.0909091002440.28070@V090114053VZO-1>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	dhowells@redhat.com, lethal@linux-sh.org, kernel@wantstofly.org,
	mpm@selenic.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753372AbZIIOmk@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909091002440.28070@V090114053VZO-1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 09, 2009 at 10:04:20AM -0400, Christoph Lameter wrote:
> On Tue, 8 Sep 2009, Paul E. McKenney wrote:
> 
> > > No direct request but I have seen the network developers discover these
> > > features and their caching benefits over the last year. It is likely that
> > > they will try to push it into more components of the net subsystem.
> >
> > So if they push it far enough, they might well decide that they need
> > a SLAB_DESTROY_BY_RCU_BH, for example.  Looks like seven bits left,
> > so unless I am missing something, should not be a huge problem should
> > this need arise.
> 
> I'd rather have the call_rcu in the slabs replaced by a function that
> can be set by the user. Then we can remove all rcu barriers from the code
> and the slabs could be used with any type of rcu functionality.

If the embedded guys are OK with an additional pointer in the slab data
structure, I have no objection to this approach.  I am assuming that we
would use the usual ops-style structure full of pointers to functions
in order to avoid a pair of extra pointers.

							Thanx, Paul
