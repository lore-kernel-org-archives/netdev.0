From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Mon, 8 Oct 2012 23:31:15 +0200
Message-ID: <20121008213114.GB17820@redhat.com>
References: <cover.1348824232.git.mst@redhat.com>
	<87vces2gxq.fsf@rustcorp.com.au> <87mx033u74.fsf@codemonkey.ws>
	<87391u3o67.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <levinsasha928@gmail.com>,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Anthony Liguori <anthony@codemonkey.ws>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87391u3o67.fsf@rustcorp.com.au>
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

On Thu, Oct 04, 2012 at 01:04:56PM +0930, Rusty Russell wrote:
> Anthony Liguori <anthony@codemonkey.ws> writes:
> > Rusty Russell <rusty@rustcorp.com.au> writes:
> >
> >> "Michael S. Tsirkin" <mst@redhat.com> writes:
> >>
> >>> Thinking about Sasha's patches, we can reduce ring usage
> >>> for virtio net small packets dramatically if we put
> >>> virtio net header inline with the data.
> >>> This can be done for free in case guest net stack allocated
> >>> extra head room for the packet, and I don't see
> >>> why would this have any downsides.
> >>
> >> I've been wanting to do this for the longest time... but...
> >>
> >>> Even though with my recent patches qemu
> >>> no longer requires header to be the first s/g element,
> >>> we need a new feature bit to detect this.
> >>> A trivial qemu patch will be sent separately.
> >>
> >> There's a reason I haven't done this.  I really, really dislike "my
> >> implemention isn't broken" feature bits.  We could have an infinite
> >> number of them, for each bug in each device.
> >
> > This is a bug in the specification.
> >
> > The QEMU implementation pre-dates the specification.  All of the actual
> > implementations of virtio relied on the semantics of s/g elements and
> > still do.
> 
> lguest fix is pending in my queue.  lkvm and qemu are broken; lkvm isn't
> ever going to be merged, so I'm not sure what its status is?  But I'm
> determined to fix qemu, and hence my torture patch to make sure this
> doesn't creep in again.

If you look at my patch you'll notice there's also a
comment in virtio_net.h that seems to be broken in this respect:

/* This is the first element of the scatter-gather list.  If you don't
 * specify GSO or CSUM features, you can simply ignore the header. */

There is a similar comment in virtio-blk.
