From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 13 Aug 2009 16:58:06 +0200
Message-ID: <200908131658.06522.arnd@arndb.de>
References: <cover.1249930169.git.mst@redhat.com> <200908131538.44465.arnd@arndb.de> <20090813143922.GA5080@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090813143922.GA5080@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 13 August 2009, Michael S. Tsirkin wrote:
> > Right now, the number of copy operations in your code is the same.
> > You are doing the copy a little bit later in skb_copy_datagram_iovec(),
> > which is indeed a very nice hack. Changing to a virtqueue based method
> > would imply that the host needs to add each skb_frag_t to its outbound
> > virtqueue, which then gets copied into the guests inbound virtqueue.
> 
> Which is a lot more code than just calling skb_copy_datagram_iovec.

Well, I don't see this part as much of a problem, because the code
already exists in virtio_net. If we really wanted to go down that road,
just using virtio_net would solve the problem of frame handling
entirely, but create new problems elsewhere, as we have mentioned.

	Arnd <><
