From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/5] /dev/vring: simple userspace-kernel ringbuffer
	interface.
Date: Sun, 20 Apr 2008 02:05:31 +1000
Message-ID: <200804200205.31508.rusty@rustcorp.com.au>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804181439.49051.rusty@rustcorp.com.au>
	<20080419102214.GA21952@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20080419102214.GA21952@2ka.mipt.ru>
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

On Saturday 19 April 2008 20:22:15 Evgeniy Polyakov wrote:
> Hi.
>
> On Fri, Apr 18, 2008 at 02:39:48PM +1000, Rusty Russell 
(rusty@rustcorp.com.au) wrote:
> > +int vring_get_buffer(struct vring_info *vr,
> > +		     struct iovec *in_iov,
> > +		     unsigned int *num_in, unsigned long *in_len,
> > +		     struct iovec *out_iov,
> > +		     unsigned int *num_out, unsigned long *out_len)
> > +{
> > +	unsigned int i, in = 0, out = 0;
> > +	unsigned long dummy;
> > +	u16 avail, last_avail, head;
> > +	struct vring_desc d;
>
> Should this whole function and vring_used_buffer() be protected with
> vr->lock mutex?

No; it's up to the caller to make sure that they are serialized.  In the case 
of tun that happens naturally.

There are two reasons not to grab the lock.  It turns out that if we tried to 
lock here, we'd deadlock, since the callbacks are called under the lock.  
Secondly, it's possible to implement an atomic vring_used_buffer variant, 
which could fail: this would avoid using the thread most of the time.

Hope that helps,
Rusty.
