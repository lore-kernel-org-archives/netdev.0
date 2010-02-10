From: Xin Xiaohui <xiaohui.xin@intel.com>
Subject: [PATCH 0/3] Provide a zero-copy method on KVM virtio-net.
Date: Wed, 10 Feb 2010 19:48:57 +0800
Message-ID: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, mst@redhat.com,
	jdike@c2.user-mode-linux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
