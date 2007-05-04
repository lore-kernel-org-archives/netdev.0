From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
Date: Fri, 04 May 2007 21:45:55 +0300
Message-ID: <463B7F63.8070508@cs.helsinki.fi>
References: <20070504102651.923946304@chello.nl>	 <20070504103157.215424767@chello.nl>	 <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>	 <1178301545.24217.56.camel@twins>	 <Pine.LNX.4.64.0705041104110.23539@schroedinger.engr.sgi.com>	 <1178302904.2767.6.camel@lappy>	 <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com> <1178303538.2767.9.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52839 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161600AbXEDSpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 14:45:42 -0400
In-Reply-To: <1178303538.2767.9.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-05-04 at 11:30 -0700, Christoph Lameter wrote:
> > Hmmm... Maybe lets have
> >
> > unsigned kmem_estimate_pages(struct kmem_cache *slab_cache, int objects)
> >
> > which would calculate the worst case memory scenario for allocation the 
> > number of indicated objects?

On Fri, 4 May 2007, Peter Zijlstra wrote:
> Perfectly fine with me, Pekka, any objections?

Again, slab has no way of actually estimating how many pages you need 
for a given number of objects. So we end up calculating some upper bound 
which doesn't belong in mm/slab.c. I am perfectly okay with:

   (1) kmem_nr_bytes_per_object which is what Peter has now

or alternatively,

   (2) kmem_nr_objects_per_page which I think Christoph suggested

Both of them, the slab knows the answer, and doesn't need to guess. It's 
up to the caller to figure out what the acceptable upper bound is.

			Pekka
