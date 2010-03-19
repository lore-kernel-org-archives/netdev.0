From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [E1000-devel] recent e100 fixes cause kernel panic?
Date: Fri, 19 Mar 2010 13:16:39 -0700
Message-ID: <20100319131639.733c53bf@nehalam>
References: <12968172.251031268372359953.JavaMail.root@tahiti.vyatta.com>
	<1269027740.3029.33.camel@jbrandeb-mobl3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ed Ravin <eravin@panix.com>, roger.oksanen@cs.helsinki.fi,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45598 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219Ab0CSUQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 16:16:56 -0400
In-Reply-To: <1269027740.3029.33.camel@jbrandeb-mobl3.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Mar 2010 12:42:20 -0700
Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:

> Added netdev, the place to talk about in-kernel driver problems.
> 
> On Thu, 2010-03-11 at 22:39 -0700, Stephen Hemminger wrote:
> > ----- "Ed Ravin" <eravin@panix.com> wrote:
> > 
> > > I'm using the Vyatta "kenwood" Linux distribution, which is currently
> > > at 2.6.31-1.  I upgraded to their latest version, and began seeing
> > > kernel
> > > panics shortly after starting to use ssh/scp on the network connected
> > > to
> > > an e100 NIC.  I was able to reproduce the problem immediately after
> > > booting up - sometimes it even crashed during the boot.
> > > 
> > > One of the crash logs is attached.
> 
> Ed, thanks for the report, looks like these patches introduced a new
> problem.  e100 hardware has a tricky data structure that seems to cause
> some problems for (particularly arm) some cpu architectures.
> 
> > > 
> > > Since the problem seemed to be related to e100.c, I reverted the two
> > > commits to e100.c that had taken place since I last built the kernel
> > > for this box:
> > > 
> > >   Author: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
> > >   Date:   Fri Dec 18 20:18:21 2009 -0800
> > >   e100: Fix broken cbs accounting due to missing memset.
> > > 
> > >   Author: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
> > >   Date:   Sun Nov 29 17:17:29 2009 -0800
> > >   e100: Use pci pool to work around GFP_ATOMIC order 5 memory
> > > allocation failu
> > > 
> > > I rebuilt the kernel and it's not panicking anymore.
> 
> so you just reverted both, and its good news things are working again,
> but can you try one or the other and let us know if things still break
> for you?
> 
> > The Vyatta kernel for 2.6.31 is based on the 2.6.31.10 + unionfs.
> > These two patches came from the 2.6.31.10 -stable update.
> 
> This is the only report of this issue I have heard so far, so something
> must be a little unique to your system or workload such that the driver
> works mostly.
> 
> I'm looking more closely into the panic trace now, maybe I can figure it
> out from there.
> 

Davem found one thing, the memset wasn't initializing the whole maximum possible
tx ring.

-- 
