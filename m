From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 18:42:23 +0100
Message-ID: <20161125174223.GS3092@twins.programming.kicks-ass.net>
References: <32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
	<20161125122356.GB26611@leverpostej>
	<20161125124044.GN3092@twins.programming.kicks-ass.net>
	<20161125124404.GI3174@twins.programming.kicks-ass.net>
	<20161125145512.GA4014@Boquns-MacBook-Pro.local>
	<CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
	<20161125161004.GA30181@leverpostej>
	<20161125161709.GQ3092@twins.programming.kicks-ass.net>
	<d7f3740b-e343-68fc-4996-f712dd8c07f3@de.ibm.com>
	<20161125172624.GA30811@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Davidlohr Bueso <dave@stgolabs.net>, KVM list <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev <netdev@vger.kernel.org>,
	Boqun Feng <boqun.feng@gmail.com>, dbueso@suse.de,
	LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Dmitry Vyukov <dvyukov@google.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20161125172624.GA30811@leverpostej>
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

On Fri, Nov 25, 2016 at 05:28:01PM +0000, Mark Rutland wrote:
> On Fri, Nov 25, 2016 at 05:49:45PM +0100, Christian Borntraeger wrote:
> > On 11/25/2016 05:17 PM, Peter Zijlstra wrote:

> > There were several cases that I found during writing the *ONCE stuff.
> > For example there are some 32bit ppc variants with 64bit PTEs. Some for
> > others (I think sparc).
> 
> We have similar on 32-bit ARM w/ LPAE. LPAE implies that a naturally
> aligned 64-bit access is single-copy atomic, which is what makes that
> ok.
> 
> > And the mm/ code is perfectly fine with these PTE accesses being done
> > NOT atomic.
> 
> That strikes me as surprising. Is there some mutual exclusion that
> prevents writes from occuring wherever a READ_ONCE() happens to a PTE?
> 
> Otherwise, how is tearing not a problem? Does it have some pattern like
> the lockref cmpxchg?

On x86 PAE we play silly games, see arch/x86/mm/gup.c:gup_get_ptr().

Those two loads really should be READ_ONCE()/LOAD_SINGLE().
