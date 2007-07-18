From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [Bugme-new] [Bug 8778] New: Ocotea board: kernel reports
	access of bad area during boot with DEBUG_SLAB=y
Date: Wed, 18 Jul 2007 11:28:47 -0500
Message-ID: <1184776127.16299.22.camel@weaponx.rchland.ibm.com>
References: <bug-8778-10286@http.bugzilla.kernel.org/>
	 <20070718005253.942f0464.akpm@linux-foundation.org>
	 <20070718083425.GA29722@gate.ebshome.net>
	 <1184766070.3699.2.camel@zod.rchland.ibm.com>
	 <20070718155940.GB29722@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bart.vanassche@gmail.com, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, linuxppc-embedded@ozlabs.org
To: Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:57685 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934210AbXGRQ2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 12:28:51 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6IGSngZ009267
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 12:28:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6IGSnDd234056
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 10:28:49 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6IGSmp3004757
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 10:28:49 -0600
In-Reply-To: <20070718155940.GB29722@gate.ebshome.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-18 at 08:59 -0700, Eugene Surovegin wrote:
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

Hm... good point.  I'd still like to see if your patch works around the
reporter's problem.

josh

