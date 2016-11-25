From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 13:44:04 +0100
Message-ID: <20161125124404.GI3174@twins.programming.kicks-ass.net>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
	<20161124222357-mutt-send-email-mst@kernel.org>
	<20161125112203.GA26611@leverpostej>
	<32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
	<20161125122356.GB26611@leverpostej>
	<20161125124044.GN3092@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dave@stgolabs.net, kvm@vger.kernel.org, dbueso@suse.de,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	paulmck@linux.vnet.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>,
	dvyukov@google.com
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20161125124044.GN3092@twins.programming.kicks-ass.net>
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

On Fri, Nov 25, 2016 at 01:40:44PM +0100, Peter Zijlstra wrote:
> #define SINGLE_LOAD(x)						\
> {(								\
> 	compiletime_assert_atomic_type(typeof(x));		\

Should be:

	compiletime_assert_atomic_type(x);

> 	WARN_SINGLE_COPY_ALIGNMENT(&(x));			\
> 	READ_ONCE(x);						\
> })
> 
> #define SINGLE_STORE(x, v)					\
> ({								\
> 	compiletime_assert_atomic_type(typeof(x));		\

idem

> 	WARN_SINGLE_COPY_ALIGNMENT(&(x));			\
> 	WRITE_ONCE(x, v);					\
> })
