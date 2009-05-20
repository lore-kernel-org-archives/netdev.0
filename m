From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [BUG 2.6.30-rc1] panic when loading oprofile
Date: Wed, 20 May 2009 00:13:24 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A335277B5@orsmsx507.amr.corp.intel.com>
References: <alpine.WNT.2.00.0905131327430.7052__41366.1100705669$1242253861$gmane$org@jbrandeb-desk1.amr.corp.intel.com>
	<87fxf6pmh5.fsf@basil.nowhere.org>
 <20090516162017.2525511c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"oprofile-list@lists.sourceforge.net"
	<oprofile-list@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>
To: Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40589 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269AbZETHNZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 03:13:25 -0400
In-Reply-To: <20090516162017.2525511c.akpm@linux-foundation.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Fri, 15 May 2009 14:41:26 +0200 Andi Kleen <andi@firstfloor.org>
> wrote:
>
> > "Brandeburg, Jesse" <jesse.brandeburg@intel.com> writes:
> >
> > Hi Jesse,
> >
> > > when starting a profile run on the latest net-next kernel, I'm
> currently
> > > trying to reproduce on 2.6.30-rc5 stock.
> >
> > Were you able to reproduce it?

For some reason I can no longer reproduce, I'll add a note to the bug too.

My suspicion is my normal process of
git pull
make O=../foo
make modules_install install

somehow picked up the L1_CACHE_BYTES=128 and stuck with it.  I can no longer reproduce that at all, .config always has the same result.

It also may have been that the problem self repaired when I had to blow away my .oprofile/daemonrc because shortly after these panics my oprofile stopped working on older kernels too.

Sorry for the inconvenience, it was reproducible when I started :-(

> >
> > >
> > > config available upon request, arch=x86_64, recent (F10 or newer)
> oprofile
> > > userspace.
> >
> > it looks like two bugs: oprofile didn't catch a NMI that belongs to
> > it (most likely) and the NMI watchdog referenced a NULL pointer
> > while processing an NMI.
> >
> > Did you have the nmi watchdog enabled on the command line?
> >
> > >
> > > BUG: unable to handle kernel NULL pointer dereference at (null)
> > > IP: [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6


<snip>

> Ping?
>
> This is in Rafael's regression list but I suspect that it's a
> linux-next-only thing?

We can close, unreproducable.  Its bugzilla 13324
