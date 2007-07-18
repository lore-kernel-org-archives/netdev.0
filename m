From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [Bugme-new] [Bug 8778] New: Ocotea board: kernel reports access of bad area during boot with DEBUG_SLAB=y
Date: Wed, 18 Jul 2007 08:59:40 -0700
Message-ID: <20070718155940.GB29722@gate.ebshome.net>
References: <bug-8778-10286@http.bugzilla.kernel.org/> <20070718005253.942f0464.akpm@linux-foundation.org> <20070718083425.GA29722@gate.ebshome.net> <1184766070.3699.2.camel@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bart.vanassche@gmail.com, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, linuxppc-embedded@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:34166 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759853AbXGRP7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 11:59:41 -0400
Content-Disposition: inline
In-Reply-To: <1184766070.3699.2.camel@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 18, 2007 at 08:41:10AM -0500, Josh Boyer wrote:
> On Wed, 2007-07-18 at 01:34 -0700, Eugene Surovegin wrote:
> > On Wed, Jul 18, 2007 at 12:52:53AM -0700, Andrew Morton wrote:
> > > On Wed, 18 Jul 2007 00:07:50 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> > > 
> > > > http://bugzilla.kernel.org/show_bug.cgi?id=8778
> > > > 
> > > >            Summary: Ocotea board: kernel reports access of bad area during
> > > >                     boot with DEBUG_SLAB=y
> > 
> > Slab debugging is probably the culprit here. I had similar problem 
> > couple of years ago, not sure something has changed since then, 
> > haven't checked.
> > 
> > When slab debugging was enabled it made memory allocations non L1 
> > cache line aligned. This is very bad for DMA on non-coherent cache 
> > arches (PPC440 is one of those archs).
> > 
> > I have a hack for EMAC which tries to "workaround" this problem:
> > 	http://kernel.ebshome.net/emac_slab_debug.diff
> > which might help.
> 
> Would you be opposed to including that patch in mainline?

Yes. I don't think it's the right way to fix this issue. IMO, the 
right one is to fix slab allocator. You cannot change all drivers to 
do this kind of cache flushing, and yes, I saw the same problem with 
PCI based NIC I tried on Ocotea at the time.

-- 
Eugene
