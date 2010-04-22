From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][PATCH v2 0/3] Provide a zero-copy method on KVM
	virtio-net.
Date: Thu, 22 Apr 2010 12:19:43 +0300
Message-ID: <20100422091943.GA30532@redhat.com>
References: <1270193100-6769-1-git-send-email-xiaohui.xin@intel.com> <20100414152519.GA10792@redhat.com> <97F6D3BD476C464182C1B7BABF0B0AF5C18969CC@shzsmsx502.ccr.corp.intel.com> <20100415100546.GA17035@redhat.com> <F2E9EB7348B8264F86B6AB8151CE2D79026FA95401@shsmsx502.ccr.corp.intel.com> <20100419102118.GA16198@redhat.com> <F2E9EB7348B8264F86B6AB8151CE2D79026FAB1E5F@shsmsx502.ccr.corp.intel.com> <20100421083507.GA30855@redhat.com> <F2E9EB7348B8264F86B6AB8151CE2D79026FAE0BDB@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D79026FAE0BDB@shsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 22, 2010 at 04:57:56PM +0800, Xin, Xiaohui wrote:
> Michael,
> 
> >Yes, I think this packet split mode probably maps well to mergeable buffer
> >support. Note that
> >1. Not all devices support large packets in this way, others might map
> >   to indirect buffers better
> 
> Do the indirect buffers accord to deal with the skb->frag_list?

We currently use skb->frags.

> >   So we have to figure out how migration is going to work
> Yes, different guest virtio-net driver may contain different features.
> Does the qemu migration work with different features supported by virtio-net
> driver now?

For now, you must have identical feature-sets for migration to work.
And long as we manage the buffers in software, we can always make
features match.

> >2. It's up to guest driver whether to enable features such as
> >   mergeable buffers and indirect buffers
> >   So we have to figure out how to notify guest which mode
> >   is optimal for a given device
> Yes. When a device is binded, the mp device may query the capabilities from driver.
> Actually, there is a structure now in mp device can do this, we can add some field
> to support more.
> 
> >3. We don't want to depend on jumbo frames for decent performance
> >   So we probably should support GSO/GRO
> GSO is for the tx side, right? I think driver can handle it itself.
> For GRO, I'm not sure it's easy or not. Basically, the mp device now
> we have support is doing what raw socket is doing. The packets are not going to host stack.

See commit bfd5f4a3d605e0f6054df0b59fe0907ff7e696d3
(it doesn't currently work with vhost net, but that's
 a separate story).

> -- 
> MST
