From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 16:32:21 +0000
Message-ID: <20161125163220.GB30181@leverpostej>
References: <20161124222357-mutt-send-email-mst@kernel.org>
 <20161125112203.GA26611@leverpostej>
 <32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
 <20161125122356.GB26611@leverpostej>
 <20161125124044.GN3092@twins.programming.kicks-ass.net>
 <20161125124404.GI3174@twins.programming.kicks-ass.net>
 <20161125145512.GA4014@Boquns-MacBook-Pro.local>
 <CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
 <20161125161004.GA30181@leverpostej>
 <20161125161709.GQ3092@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Boqun Feng <boqun.feng@gmail.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Davidlohr Bueso <dave@stgolabs.net>, dbueso@suse.de,
        jasowang@redhat.com, KVM list <kvm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        virtualization@lists.linux-foundation.org,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161125161709.GQ3092@twins.programming.kicks-ass.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 25, 2016 at 05:17:09PM +0100, Peter Zijlstra wrote:
> On Fri, Nov 25, 2016 at 04:10:04PM +0000, Mark Rutland wrote:
> > On Fri, Nov 25, 2016 at 04:21:39PM +0100, Dmitry Vyukov wrote:
> 
> > > What are use cases for such primitive that won't be OK with "read once
> > > _and_ atomically"?
> > 
> > I have none to hand.
> 
> Whatever triggers the __builtin_memcpy() paths, and even the size==8
> paths on 32bit.

Lockref, per:

http://lkml.iu.edu/hypermail/linux/kernel/1503.3/02294.html

In that specific case, a torn value just means we'll retry until we get
a non torn value, due to the cmpxchg. For that case, all we need is the
value to be reloaded per invocation of READ_ONCE().

This guy seems to have the full story:

http://lkml.iu.edu/hypermail/linux/kernel/1503.3/02389.html
http://lkml.iu.edu/hypermail/linux/kernel/1503.3/02558.html

Thanks,
Mark.
