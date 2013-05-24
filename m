From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: updated: kvm networking todo wiki
Date: Fri, 24 May 2013 08:47:58 -0500
Message-ID: <8738tctrox.fsf@codemonkey.ws>
References: <20130523085034.GA16142@redhat.com> <519F35B7.6010408@redhat.com> <20130524113542.GA7046@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, sri@linux.vnet.ibm.com,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Shirley Ma <mashirle@us.ibm.com>,
	"Xin\, Xiaohui" <xiaohui.xin@intel.com>, jdike@linux.intel.com,
	herbert@gondor.hengli.com.au, lmr@redhat.com, akong@redhat.com,
	vyasevic@redhat.com, sriram.narasimhan@hp.com, kvm@vger.kernel.org,
	qemu-devel@nongnu.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20130524113542.GA7046@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> writes:

> On Fri, May 24, 2013 at 05:41:11PM +0800, Jason Wang wrote:
>> On 05/23/2013 04:50 PM, Michael S. Tsirkin wrote:
>> > Hey guys,
>> > I've updated the kvm networking todo wiki with current projects.
>> > Will try to keep it up to date more often.
>> > Original announcement below.
>> 
>> Thanks a lot. I've added the tasks I'm currently working on to the wiki.
>> 
>> btw. I notice the virtio-net data plane were missed in the wiki. Is the
>> project still being considered?
>
> It might have been interesting several years ago, but now that linux has
> vhost-net in kernel, the only point seems to be to
> speed up networking on non-linux hosts.

Data plane just means having a dedicated thread for virtqueue processing
that doesn't hold qemu_mutex.

Of course we're going to do this in QEMU.  It's a no brainer.  But not
as a separate device, just as an improvement to the existing userspace
virtio-net.

> Since non-linux does not have kvm, I doubt virtio is a bottleneck.

FWIW, I think what's more interesting is using vhost-net as a networking
backend with virtio-net in QEMU being what's guest facing.

In theory, this gives you the best of both worlds: QEMU acts as a first
line of defense against a malicious guest while still getting the
performance advantages of vhost-net (zero-copy).

> IMO yet another networking backend is a distraction,
> and confusing to users.
> In any case, I'd like to see virtio-blk dataplane replace
> non dataplane first. We don't want two copies of
> virtio-net in qemu.

100% agreed.

Regards,

Anthony Liguori

>
>> > ----
>> >
>> > I've put up a wiki page with a kvm networking todo list,
>> > mainly to avoid effort duplication, but also in the hope
>> > to draw attention to what I think we should try addressing
>> > in KVM:
>> >
>> > http://www.linux-kvm.org/page/NetworkingTodo
>> >
>> > This page could cover all networking related activity in KVM,
>> > currently most info is related to virtio-net.
>> >
>> > Note: if there's no developer listed for an item,
>> > this just means I don't know of anyone actively working
>> > on an issue at the moment, not that no one intends to.
>> >
>> > I would appreciate it if others working on one of the items on this list
>> > would add their names so we can communicate better.  If others like this
>> > wiki page, please go ahead and add stuff you are working on if any.
>> >
>> > It would be especially nice to add autotest projects:
>> > there is just a short test matrix and a catch-all
>> > 'Cover test matrix with autotest', currently.
>> >
>> > Currently there are some links to Red Hat bugzilla entries,
>> > feel free to add links to other bugzillas.
>> >
>> > Thanks!
>> >
