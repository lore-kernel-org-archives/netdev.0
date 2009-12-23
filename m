From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 11:13:40 +0100
Message-ID: <20091223101340.GC20539@basil.fritz.box>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50790 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbZLWKNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 05:13:42 -0500
Content-Disposition: inline
In-Reply-To: <20091223065129.GA19600@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> i.e. it has all the makings of a stupid, avoidable, permanent fork. The thing 

Nearly. There was no equivalent of a kernel based virtual driver host
before.

> - Are a pure software concept and any compatibility mismatch is                                      
>   self-inflicted. The patches are in fact breaking the ABI to KVM                                                

In practice, especially considering older kernel releases, VMs 
behave like hardware, with all its quirks, compatibility requirements,
sometimes not fully understood, etc.

> is, if AlacricityVM is better, and KVM developers are not willing to fix their 
> stuff, replace KVM with it.

In the end the driver model is only a very small part of KVM though.

> 
> It's a bit as if someone found a performance problem with sys_open() and came 
> up with sys_open_v2() and claimed that he wants to work with the VFS 
> developers while not really doing so but advances sys_open_v2() all the time. 

AFAIK Gregory tried for several months to work with the KVM maintainers,
but failed at their NIH filter.

> 
> Do we allow sys_open_v2() upstream, in the name of openness and diversity, 
> letting some apps use that syscall while other apps still use sys_open()? Or 
> do we say "enough is enough of this stupidity, come up with some strong 
> reasons to replace sys_open, and if so, replace the thing and be done with the 
> pain!".

I thought the published benchmark numbers were strong reasons.
I certainly haven't seen similarly convincing numbers for vhost-net.

> The main difference is that Gregory claims that improved performance is not 
> possible within the existing KVM framework, while the KVM developers disagree. 
> The good news is that this is a hard, testable fact.

Yes clearly the onus at this point is on the vhost-net developers/
"pci is all that is ever needed for PV" proponents to show similar numbers
with their current code.

If they can show the same performance there's really no need for
the alacrityvm model (or at least I haven't seen a convincing reason
other than performance so far to have a separate model)

I heard claims earlier from one side to the other that some benchmarks
were not fair. Apart from such accusations not being very constructive
(I don't think anyone is trying to intentionally mislead others here), 
but even if that's the case surely the other side can do similar 
benchmarks and demonstrate they are as fast.

-Andi
