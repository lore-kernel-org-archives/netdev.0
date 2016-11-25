From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 10:47:32 -0800
Message-ID: <CA+55aFwwm=NA_KcxL2GQdqN=d4fLd+swLkSJYWsjV-kL61BrWg@mail.gmail.com>
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
	<20161125180649.GC30811@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Davidlohr Bueso <dave@stgolabs.net>, KVM list <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, netdev <netdev@vger.kernel.org>,
	Boqun Feng <boqun.feng@gmail.com>, Davidlohr Bueso <dbueso@suse.de>,
	LKML <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20161125180649.GC30811@leverpostej>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 25, 2016 at 10:07 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Nov 25, 2016 at 09:52:50AM -0800, Linus Torvalds wrote:
>> READ/WRITE_ONCE() are atomic *WHEN*THAT*IS*POSSIBLE*.
>
>> But sometimes it's not going to be atomic.
>
> That's the problem.

It has never really been much of a problem, and quite frankly, the
solution would never be to add _another_ crazy new function that will
just confuse everybody.

If you have code that depends on atomicity of READ_ONCE() and friends,
then you should add the appropriate built-time assert to *your* code.
Not to some random generic function that others care about and that
others do _not_ have problems with.

So if you have a data structure in virtio that is
architecture-dependent and might not be a word size, you add the

   BUILD_BUG_ON(sizeof(mytype) > sizeof(long));

or whatever. With a big comment saying "this needs to actually fit in
a single register so that we can do atomic accesses".

You do not screw it up for everybody else.

                Linus
