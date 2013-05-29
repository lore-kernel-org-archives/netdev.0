From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: updated: kvm networking todo wiki
Date: Wed, 29 May 2013 17:12:39 +0300
Message-ID: <20130529141239.GB10347@redhat.com>
References: <20130523085034.GA16142@redhat.com> <519F35B7.6010408@redhat.com>
	<20130524113542.GA7046@redhat.com> <8738tctrox.fsf@codemonkey.ws>
	<20130524140024.GA12024@redhat.com>
	<87li6yodgq.fsf@rustcorp.com.au> <87k3miq6sw.fsf@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, lmr@redhat.com, "Xin,
	Xiaohui" <xiaohui.xin@intel.com>,
	Shirley Ma <mashirle@us.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Stevens <dlstevens@us.ibm.com>, qemu-devel@nongnu.org,
	vyasevic@redhat.com, herbert@gondor.hengli.com.au,
	jdike@linux.intel.com, sri@linux.vnet.ibm.com
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87k3miq6sw.fsf@codemonkey.ws>
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

On Wed, May 29, 2013 at 08:01:03AM -0500, Anthony Liguori wrote:
> Rusty Russell <rusty@rustcorp.com.au> writes:
> 
> > "Michael S. Tsirkin" <mst@redhat.com> writes:
> >> On Fri, May 24, 2013 at 08:47:58AM -0500, Anthony Liguori wrote:
> >>> "Michael S. Tsirkin" <mst@redhat.com> writes:
> >>> 
> >>> > On Fri, May 24, 2013 at 05:41:11PM +0800, Jason Wang wrote:
> >>> >> On 05/23/2013 04:50 PM, Michael S. Tsirkin wrote:
> >>> >> > Hey guys,
> >>> >> > I've updated the kvm networking todo wiki with current projects.
> >>> >> > Will try to keep it up to date more often.
> >>> >> > Original announcement below.
> >>> >> 
> >>> >> Thanks a lot. I've added the tasks I'm currently working on to the wiki.
> >>> >> 
> >>> >> btw. I notice the virtio-net data plane were missed in the wiki. Is the
> >>> >> project still being considered?
> >>> >
> >>> > It might have been interesting several years ago, but now that linux has
> >>> > vhost-net in kernel, the only point seems to be to
> >>> > speed up networking on non-linux hosts.
> >>> 
> >>> Data plane just means having a dedicated thread for virtqueue processing
> >>> that doesn't hold qemu_mutex.
> >>> 
> >>> Of course we're going to do this in QEMU.  It's a no brainer.  But not
> >>> as a separate device, just as an improvement to the existing userspace
> >>> virtio-net.
> >>> 
> >>> > Since non-linux does not have kvm, I doubt virtio is a bottleneck.
> >>> 
> >>> FWIW, I think what's more interesting is using vhost-net as a networking
> >>> backend with virtio-net in QEMU being what's guest facing.
> >>> 
> >>> In theory, this gives you the best of both worlds: QEMU acts as a first
> >>> line of defense against a malicious guest while still getting the
> >>> performance advantages of vhost-net (zero-copy).
> >>
> >> Great idea, that sounds very intresting.
> >>
> >> I'll add it to the wiki.
> >>
> >> In fact a bit of complexity in vhost was put there in the vague hope to
> >> support something like this: virtio rings are not translated through
> >> regular memory tables, instead, vhost gets a pointer to ring address.
> >>
> >> This allows qemu acting as a man in the middle,
> >> verifying the descriptors but not touching the
> >>
> >> Anyone interested in working on such a project?
> >
> > It would be an interesting idea if we didn't already have the vhost
> > model where we don't need the userspace bounce.
> 
> The model is very interesting for QEMU because then we can use vhost as
> a backend for other types of network adapters (like vmxnet3 or even
> e1000).
> 
> It also helps for things like fault tolerance where we need to be able
> to control packet flow within QEMU.
> 
> Regards,
> 
> Anthony Liguori

It was also floated as an alternative way to do live migration.

> > We already have two
> > sets of host side ring code in the kernel (vhost and vringh, though
> > they're being unified).
> >
> > All an accelerator can offer on the tx side is zero copy and direct
> > update of the used ring.  On rx userspace could register the buffers and
> > the accelerator could fill them and update the used ring.  It still
> > needs to deal with merged buffers, for example.
> >
> > You avoid the address translation in the kernel, but I'm not convinced
> > that's a key problem.
> >
> > Cheers,
> > Rusty.
