From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/5] /dev/vring: simple userspace-kernel ringbuffer
	interface.
Date: Sun, 20 Apr 2008 02:45:59 +1000
Message-ID: <200804200246.00282.rusty@rustcorp.com.au>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804200205.31508.rusty@rustcorp.com.au>
	<20080419163322.GA17089@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20080419163322.GA17089@2ka.mipt.ru>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sunday 20 April 2008 02:33:22 Evgeniy Polyakov wrote:
> On Sun, Apr 20, 2008 at 02:05:31AM +1000, Rusty Russell 
(rusty@rustcorp.com.au) wrote:
> > There are two reasons not to grab the lock.  It turns out that if we
> > tried to lock here, we'd deadlock, since the callbacks are called under
> > the lock. Secondly, it's possible to implement an atomic
> > vring_used_buffer variant, which could fail: this would avoid using the
> > thread most of the time.
>
> Yep, I decided that too. But it limits its usage to tun only or any
> other system where only single thread picks up results, so no generic
> userspace ring buffers?

I don't think so, it just externalizes the locking.  The mutex protects the 
attaching and detaching of the ops structure, some other lock or code 
protects simultenous kernel ring accesses.

Cheers,
Rusty.
