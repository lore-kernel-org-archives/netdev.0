From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 16:10:04 +0000
Message-ID: <20161125161004.GA30181@leverpostej>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
 <20161124222357-mutt-send-email-mst@kernel.org>
 <20161125112203.GA26611@leverpostej>
 <32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
 <20161125122356.GB26611@leverpostej>
 <20161125124044.GN3092@twins.programming.kicks-ass.net>
 <20161125124404.GI3174@twins.programming.kicks-ass.net>
 <20161125145512.GA4014@Boquns-MacBook-Pro.local>
 <CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Boqun Feng <boqun.feng@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Davidlohr Bueso <dave@stgolabs.net>, dbueso@suse.de,
        jasowang@redhat.com, KVM list <kvm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        virtualization@lists.linux-foundation.org,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 25, 2016 at 04:21:39PM +0100, Dmitry Vyukov wrote:
> 
> READ/WRITE_ONCE imply atomicity. Even if their names don't spell it (a
> function name doesn't have to spell all of its guarantees). Most of
> the uses of READ/WRITE_ONCE will be broken if they are not atomic.

In practice, this is certainly the assumption made by many/most users of
the *_ONCE() accessors.

Looking again, Linus does seem to agree that word-sized accesses should
result in single instructions (and be single-copy atomic) [1], so in
contrast to [2], that's clearly *part* of the point of the *_ONCE()
accessors...

> "Read once but not necessary atomically" is a very subtle primitive
> which is very easy to misuse.

I agree. Unfortunately, Linus does not appear to [2].

> What are use cases for such primitive that won't be OK with "read once
> _and_ atomically"?

I have none to hand.

Thanks,
Mark.

[1] http://lkml.iu.edu/hypermail/linux/kernel/1503.3/02674.html
[2] http://lkml.iu.edu/hypermail/linux/kernel/1503.3/02670.html
