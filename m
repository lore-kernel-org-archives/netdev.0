From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [RFC PATCH 02/12] On Tue, 23 Sep 2008, David Miller wrote:
Date: Sun, 5 Oct 2008 09:02:26 -0700
Message-ID: <20081005090226.1e9eaae6@linux.intel.com>
References: <20080930030825.22950.18891.stgit@jbrandeb-bw.jf.intel.com>
	<200810021523.45884.jbarnes@virtuousgeek.org>
	<20081003.134634.240211201.davem@davemloft.net>
	<200810031429.22598.jbarnes@virtuousgeek.org>
	<alpine.LNX.1.10.0810032338140.26779@jikos.suse.cz>
	<4807377b0810031628x43f79eferdbb9c9c264a5816e@mail.gmail.com>
	<alpine.LNX.1.10.0810041219130.26779@jikos.suse.cz>
	<alpine.LFD.2.00.0810041236250.4404@apollo>
	<4807377b0810041824u5ea472d1q4cf5ff606bd23a11@mail.gmail.com>
	<alpine.LFD.2.00.0810050959420.3398@apollo>
	<48E8D7A5.7060508@linux.intel.com>
	<alpine.LFD.2.00.0810051752210.3398@apollo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kkeil@suse.de, agospoda@redhat.com, david.graham@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com,
	chris.jones@canonical.com, tim.gardner@canonical.com,
	airlied@gmail.com, Olaf Kirch <okir@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34000 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658AbYJEQCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 12:02:43 -0400
In-Reply-To: <alpine.LFD.2.00.0810051752210.3398@apollo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 5 Oct 2008 17:55:14 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> On Sun, 5 Oct 2008, Arjan van de Ven wrote:
> > Thomas Gleixner wrote:
> > > On Sat, 4 Oct 2008, Jesse Brandeburg wrote:
> > > > > Exactly. The access to a ro region results in a fault. I have
> > > > > nowhere seen that trigger, but I can reproduce the trylock()
> > > > > WARN_ON, which confirms that there is concurrent access to
> > > > > the NVRAM registers. The backtrace pattern is similar to the
> > > > > one you have seen.
> > > > are you still getting WARN_ON *with* all the mutex based fixes
> > > > already applied?
> > > 
> > > The WARN_ON triggers with current mainline. Is there any fixlet in
> > > Linus tree missing ?
> > > 
> > > > with the mutex patches in place (without protection patch) we
> > > > are still reproducing the issue, until we apply the
> > > > set_memory_ro patch.
> > > 
> > > That does not make sense to me. If the memory_ro patch is
> > > providing _real_ protection then you _must_ run into an access
> > > violation. If not, then the patch just papers over the real
> > > problem in some mysterious way.
> > > 
> > 
> > not if the bad code is doing copy_to_user .... (or similar)
> 
> You mean: copy_from_user :) This would require that the e1000e
> nvram region is writable via copy_from_user by an e1000e user space
> interface. A quick grep does not reviel such a horrible interface.

I meant a "copy_to_user" to a duff pointer, somewhere in the kernel.
