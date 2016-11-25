From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 17:28:01 +0000
Message-ID: <20161125172624.GA30811@leverpostej>
References: <20161125112203.GA26611@leverpostej>
 <32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
 <20161125122356.GB26611@leverpostej>
 <20161125124044.GN3092@twins.programming.kicks-ass.net>
 <20161125124404.GI3174@twins.programming.kicks-ass.net>
 <20161125145512.GA4014@Boquns-MacBook-Pro.local>
 <CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
 <20161125161004.GA30181@leverpostej>
 <20161125161709.GQ3092@twins.programming.kicks-ass.net>
 <d7f3740b-e343-68fc-4996-f712dd8c07f3@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Boqun Feng <boqun.feng@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Davidlohr Bueso <dave@stgolabs.net>, dbueso@suse.de,
        jasowang@redhat.com, KVM list <kvm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        virtualization@lists.linux-foundation.org,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:52038 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932124AbcKYR2s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 12:28:48 -0500
Content-Disposition: inline
In-Reply-To: <d7f3740b-e343-68fc-4996-f712dd8c07f3@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 05:49:45PM +0100, Christian Borntraeger wrote:
> On 11/25/2016 05:17 PM, Peter Zijlstra wrote:
> > On Fri, Nov 25, 2016 at 04:10:04PM +0000, Mark Rutland wrote:
> >> On Fri, Nov 25, 2016 at 04:21:39PM +0100, Dmitry Vyukov wrote:
> > 
> >>> What are use cases for such primitive that won't be OK with "read once
> >>> _and_ atomically"?
> >>
> >> I have none to hand.
> > 
> > Whatever triggers the __builtin_memcpy() paths, and even the size==8
> > paths on 32bit.
> > 
> > You could put a WARN in there to easily find them.
> 
> There were several cases that I found during writing the *ONCE stuff.
> For example there are some 32bit ppc variants with 64bit PTEs. Some for
> others (I think sparc).

We have similar on 32-bit ARM w/ LPAE. LPAE implies that a naturally
aligned 64-bit access is single-copy atomic, which is what makes that
ok.

> And the mm/ code is perfectly fine with these PTE accesses being done
> NOT atomic.

That strikes me as surprising. Is there some mutual exclusion that
prevents writes from occuring wherever a READ_ONCE() happens to a PTE?

Otherwise, how is tearing not a problem? Does it have some pattern like
the lockref cmpxchg?

Thanks,
Mark.
