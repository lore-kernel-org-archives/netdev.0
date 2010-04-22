From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC][PATCH v2 0/3] Provide a zero-copy method on KVM
	virtio-net.
Date: Thu, 22 Apr 2010 16:57:56 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D79026FAE0BDB@shsmsx502.ccr.corp.intel.com>
References: <1270193100-6769-1-git-send-email-xiaohui.xin@intel.com>
 <20100414152519.GA10792@redhat.com>
 <97F6D3BD476C464182C1B7BABF0B0AF5C18969CC@shzsmsx502.ccr.corp.intel.com>
 <20100415100546.GA17035@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D79026FA95401@shsmsx502.ccr.corp.intel.com>
 <20100419102118.GA16198@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D79026FAB1E5F@shsmsx502.ccr.corp.intel.com>
 <20100421083507.GA30855@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100421083507.GA30855@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,

>Yes, I think this packet split mode probably maps well to mergeable buffer
>support. Note that
>1. Not all devices support large packets in this way, others might map
>   to indirect buffers better

Do the indirect buffers accord to deal with the skb->frag_list?

>   So we have to figure out how migration is going to work
Yes, different guest virtio-net driver may contain different features.
Does the qemu migration work with different features supported by virtio-net
driver now?

>2. It's up to guest driver whether to enable features such as
>   mergeable buffers and indirect buffers
>   So we have to figure out how to notify guest which mode
>   is optimal for a given device
Yes. When a device is binded, the mp device may query the capabilities from driver.
Actually, there is a structure now in mp device can do this, we can add some field
to support more.

>3. We don't want to depend on jumbo frames for decent performance
>   So we probably should support GSO/GRO
GSO is for the tx side, right? I think driver can handle it itself.
For GRO, I'm not sure it's easy or not. Basically, the mp device now
we have support is doing what raw socket is doing. The packets are not going to host stack.
-- 
MST
