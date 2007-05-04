From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
Date: Fri, 4 May 2007 09:23:04 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705040919560.21436@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>
  <84144f020705040354r5cb74c5fj6cb8698f93ffcb83@mail.gmail.com>
 <Pine.LNX.4.64.0705040908480.21436@schroedinger.engr.sgi.com>
 <1178295355.24217.49.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@steeleye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:39126 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1031080AbXEDQXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 12:23:06 -0400
In-Reply-To: <1178295355.24217.49.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 May 2007, Peter Zijlstra wrote:

> On Fri, 2007-05-04 at 09:09 -0700, Christoph Lameter wrote:
> > On Fri, 4 May 2007, Pekka Enberg wrote:
> > 
> > > On 5/4/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > > > Expost buffer_size in order to allow fair estimates on the actual space
> > > > used/needed.
> > 
> > We already have ksize?
> 
> ksize gives the internal size, whereas these give the external size.
> 
> I need to know how much space I need to reserve, hence I need the
> external size; whereas normally you want to know how much space you have
> available, which is what ksize gives.
> 
> Didn't we have this discussion last time?

I was cced on that as far as I can tell.

The name objsize suggests the size of the object not the slab size.
If you want this then maybe call it kmem_cache_slab_size. SLUB 
distinguishes between obj_size which is the size of the struct that is 
used and slab_size which is the size of the object after alignment, adding 
debug information etc etc. See also slabinfo.c for a way to calculate 
theses sizes from user space.

If we really drop SLAB then we wont need this. SLUBs data structures are 
not opaque.
