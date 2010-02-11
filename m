From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH 0/3] Provide a zero-copy method on KVM virtio-net.
Date: Thu, 11 Feb 2010 16:54:41 +0800
Message-ID: <97F6D3BD476C464182C1B7BABF0B0AF5C11F646E@shzsmsx502.ccr.corp.intel.com>
References: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vg
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Will be in a vacation during 2/13~2/20, so email may be very slow or no replied
for your comments. But please don't hesitate to comment more, and I will address 
them after the vacation. :-)

Thanks
Xiaohui
-----Original Message-----
From: kvm-owner@vger.kernel.org [mailto:kvm-owner@vger.kernel.org] On Behalf Of Xin Xiaohui
Sent: Wednesday, February 10, 2010 7:49 PM
To: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org; mingo@elte.hu; mst@redhat.com; jdike@c2.user-mode-linux.org
Subject: [PATCH 0/3] Provide a zero-copy method on KVM virtio-net.

The idea is simple, just to pin the guest VM user space and then
let host NIC driver has the chance to directly DMA to it. 
The patches are based on vhost-net backend driver. We add a device
which provides proto_ops as sendmsg/recvmsg to vhost-net to
send/recv directly to/from the NIC driver. KVM guest who use the
vhost-net backend may bind any ethX interface in the host side to
get copyless data transfer thru guest virtio-net frontend.

We provide multiple submits and asynchronous notifiicaton to 
vhost-net too.

Our goal is to improve the bandwidth and reduce the CPU usage.
Exact performance data will be provided later. But for simple
test with netperf, we found bindwidth up and CPU % up too,
but the bindwidth up ratio is much more than CPU % up ratio.

What we have not done yet:
	To support GRO
	Performance tuning
--
To unsubscribe from this list: send the line "unsubscribe kvm" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
