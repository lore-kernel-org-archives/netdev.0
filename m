From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 17:17:09 +0100
Message-ID: <20161125161709.GQ3092@twins.programming.kicks-ass.net>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
	<20161124222357-mutt-send-email-mst@kernel.org>
	<20161125112203.GA26611@leverpostej>
	<32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
	<20161125122356.GB26611@leverpostej>
	<20161125124044.GN3092@twins.programming.kicks-ass.net>
	<20161125124404.GI3174@twins.programming.kicks-ass.net>
	<20161125145512.GA4014@Boquns-MacBook-Pro.local>
	<CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
	<20161125161004.GA30181@leverpostej>
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
In-Reply-To: <20161125161004.GA30181@leverpostej>
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

On Fri, Nov 25, 2016 at 04:10:04PM +0000, Mark Rutland wrote:
> On Fri, Nov 25, 2016 at 04:21:39PM +0100, Dmitry Vyukov wrote:

> > What are use cases for such primitive that won't be OK with "read once
> > _and_ atomically"?
> 
> I have none to hand.

Whatever triggers the __builtin_memcpy() paths, and even the size==8
paths on 32bit.

You could put a WARN in there to easily find them.

The advantage of introducing the SINGLE_{LOAD,STORE}() helpers is that
they compiletime validate this the size is 'right' and can runtime check
alignment constraints.

IE, they are strictly stronger than {READ,WRITE}_ONCE().
