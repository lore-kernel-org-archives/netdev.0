From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 18:07:03 +0000
Message-ID: <20161125180649.GC30811@leverpostej>
References: <32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
 <20161125122356.GB26611@leverpostej>
 <20161125124044.GN3092@twins.programming.kicks-ass.net>
 <20161125124404.GI3174@twins.programming.kicks-ass.net>
 <20161125145512.GA4014@Boquns-MacBook-Pro.local>
 <CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
 <20161125161004.GA30181@leverpostej>
 <20161125161709.GQ3092@twins.programming.kicks-ass.net>
 <CACT4Y+YJUUjU_FCR1FOcF2DmkkcjiRFpnU7Q4=yzbgvKv0VhyQ@mail.gmail.com>
 <CA+55aFwpUxwdgKdbwfSW59VzPCJojNg7aqBdWio5MM6RJnG5Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Boqun Feng <boqun.feng@gmail.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Davidlohr Bueso <dbueso@suse.de>,
        Jason Wang <jasowang@redhat.com>,
        KVM list <kvm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        virtualization <virtualization@lists.linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:52620 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754835AbcKYSIm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 13:08:42 -0500
Content-Disposition: inline
In-Reply-To: <CA+55aFwpUxwdgKdbwfSW59VzPCJojNg7aqBdWio5MM6RJnG5Uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 09:52:50AM -0800, Linus Torvalds wrote:
> READ/WRITE_ONCE() are atomic *WHEN*THAT*IS*POSSIBLE*.

> But sometimes it's not going to be atomic.

That's the problem.

Common code may rely on something being atomic when that's only true on
a subset of platforms. On others, it's silently "fixed" into something
that isn't atomic, and we get no diagnostic. The bug lurks beneath the
surface.

Thanks,
Mark.
