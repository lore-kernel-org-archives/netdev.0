From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH V2 0/5] macvtap TX zero copy between guest and host
 kernel
Date: Fri, 10 Dec 2010 01:51:31 -0800
Message-ID: <1291974691.2167.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset add supports for TX zero-copy between guest and host
kernel through vhost. It significantly reduces CPU utilization on the
local host on which the guest is located (It reduced 30-50% CPU usage
for vhost thread for single stream test). The patchset is based on
previous submission and comments from the community regarding when/how
to handle guest kernel buffers to be released. This is the simplest
approach I can think of after comparing with several other solutions.

This patchset includes:

1. Induce a new sock zero-copy flag, SOCK_ZEROCOPY;

2. Induce a new device flag, NETIF_F_ZEROCOPY for device can support
zero-copy;

3. Add a new struct skb_ubuf_info in skb_share_info for userspace
buffers release callback when device DMA has done for that skb;

4. Add vhost zero-copy callback in vhost when skb last refcnt is gone;
   add vhost_zerocopy_add_used_and_signal to notify guest to release TX
skb buffers.

5. Add macvtap zero-copy in lower device when sending packet is greater
than 128 bytes.

The patchset has passed netperf/netserver test on Chelsio, and
continuing test on other 10GbE NICs, like Intel ixgbe, Mellanox mlx4...
I will provide guest to host, host to guest performance data next week.

However when running stress test, vhost & virtio_net seems out of sync,
and virito_net interrupt was disabled somehow, and it stopped to send
any packet. This problem has bothered me for a long long time, I will
continue to look at this.

Please review this.

Thanks
Shirley
