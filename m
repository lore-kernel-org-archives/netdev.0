From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
Date: Fri, 04 May 2007 21:41:32 +0300
Message-ID: <463B7E5C.8030201@cs.helsinki.fi>
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>  <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>  <1178301545.24217.56.camel@twins>  <Pine.LNX.4.64.0705041104110.23539@schroedinger.engr.sgi.com> <1178302904.2767.6.camel@lappy> <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42427 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161616AbXEDSlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 14:41:21 -0400
In-Reply-To: <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter wrote:
> Hmmm... Maybe lets have
> 
> unsigned kmem_estimate_pages(struct kmem_cache *slab_cache, int objects)
> 
> which would calculate the worst case memory scenario for allocation the 
> number of indicated objects?

IIRC this looks more or less what Peter had initially. I don't like the 
API because there's no way for slab (perhaps this is different for slub) 
how many pages you really need due to per-node and per-cpu caches, etc.

It's better that the slab tells you what it actually knows and lets the 
callers figure out what a worst-case upper bound is.

				Pekka


