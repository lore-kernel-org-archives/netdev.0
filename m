From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 13 Aug 2009 17:39:22 +0300
Message-ID: <20090813143922.GA5080@redhat.com>
References: <cover.1249930169.git.mst@redhat.com> <200908121959.47222.arnd@arndb.de> <20090813060615.GC3029@redhat.com> <200908131538.44465.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753709AbZHMOko@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200908131538.44465.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 13, 2009 at 03:38:43PM +0200, Arnd Bergmann wrote:
> On Thursday 13 August 2009, Michael S. Tsirkin wrote:
> > On Wed, Aug 12, 2009 at 07:59:47PM +0200, Arnd Bergmann wrote:
> > > The trick is to swap the virtqueues instead. virtio-net is actually
> > > mostly symmetric in just the same way that the physical wires on a
> > > twisted pair ethernet are symmetric (I like how that analogy fits).
> > 
> > You need to really squint hard for it to look symmetric.
> > 
> > For example, for RX, virtio allocates an skb, puts a descriptor on a
> > ring and waits for host to fill it in. Host system can not do the same:
> > guest does not have access to host memory.
> > 
> > You can do a copy in transport to hide this fact, but it will kill
> > performance.
> 
> Yes, that is what I was suggesting all along. The actual copy operation
> has to be done by the host transport, which is obviously different from
> the guest transport that just calls the host using vring_kick().
> 
> Right now, the number of copy operations in your code is the same.
> You are doing the copy a little bit later in skb_copy_datagram_iovec(),
> which is indeed a very nice hack. Changing to a virtqueue based method
> would imply that the host needs to add each skb_frag_t to its outbound
> virtqueue, which then gets copied into the guests inbound virtqueue.

Which is a lot more code than just calling skb_copy_datagram_iovec.

> Unfortunately, this also implies that you could no longer simply use the
> packet socket interface as you do currently, as I realized only now.
> This obviously has a significant impact on your user space interface.
> 
> 	Arnd <><

And, it will remove our ability to implement zero copy
down the road (when raw sockets support it).

-- 
MST
