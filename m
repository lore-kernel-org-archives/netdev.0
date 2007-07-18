From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8778] New: Ocotea board: kernel reports access
 of bad area during boot with DEBUG_SLAB=y
Date: Wed, 18 Jul 2007 09:55:37 -0700
Message-ID: <20070718095537.d344dc0a.akpm@linux-foundation.org>
References: <bug-8778-10286@http.bugzilla.kernel.org/>
	<20070718005253.942f0464.akpm@linux-foundation.org>
	<20070718083425.GA29722@gate.ebshome.net>
	<1184766070.3699.2.camel@zod.rchland.ibm.com>
	<20070718155940.GB29722@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>, bart.vanassche@gmail.com,
	netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, linuxppc-embedded@ozlabs.org
To: Eugene Surovegin <ebs@ebshome.net>, linux-mm@kvack.org,
	Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53364 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752023AbXGRQ4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 12:56:31 -0400
In-Reply-To: <20070718155940.GB29722@gate.ebshome.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007 08:59:40 -0700 Eugene Surovegin <ebs@ebshome.net> wrote:

> On Wed, Jul 18, 2007 at 08:41:10AM -0500, Josh Boyer wrote:
> > On Wed, 2007-07-18 at 01:34 -0700, Eugene Surovegin wrote:
> > > On Wed, Jul 18, 2007 at 12:52:53AM -0700, Andrew Morton wrote:
> > > > On Wed, 18 Jul 2007 00:07:50 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> > > > 
> > > > > http://bugzilla.kernel.org/show_bug.cgi?id=8778
> > > > > 
> > > > >            Summary: Ocotea board: kernel reports access of bad area during
> > > > >                     boot with DEBUG_SLAB=y
> > > 
> > > Slab debugging is probably the culprit here. I had similar problem 
> > > couple of years ago, not sure something has changed since then, 
> > > haven't checked.
> > > 
> > > When slab debugging was enabled it made memory allocations non L1 
> > > cache line aligned. This is very bad for DMA on non-coherent cache 
> > > arches (PPC440 is one of those archs).
> > > 
> > > I have a hack for EMAC which tries to "workaround" this problem:
> > > 	http://kernel.ebshome.net/emac_slab_debug.diff
> > > which might help.
> > 
> > Would you be opposed to including that patch in mainline?
> 
> Yes. I don't think it's the right way to fix this issue. IMO, the 
> right one is to fix slab allocator. You cannot change all drivers to 
> do this kind of cache flushing, and yes, I saw the same problem with 
> PCI based NIC I tried on Ocotea at the time.
> 

hm.  It should be the case that providing SLAB_HWCACHE_ALIGN at
kmem_cache_create() time will override slab-debugging's offsetting
of the returned addresses.

Or is the problem occurring with memory which is returned from kmalloc(),
rather than from kmem_cache_alloc()?

A complete description of the problem would help here, please.
