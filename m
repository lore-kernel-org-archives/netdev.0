From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V3 0/8] macvtap/vhost TX zero copy support
Date: Wed, 20 Apr 2011 12:36:56 -0700
Message-ID: <1303328216.19336.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:39498 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647Ab1DTThL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:37:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset add supports for TX zero-copy between guest and host
kernel through vhost. It significantly reduces CPU utilization on the
local host on which the guest is located (It reduced 30-50% CPU usage
for vhost thread for single stream test). The patchset is based on
previous submission and comments from the community regarding when/how
to handle guest kernel buffers to be released. This is the simplest
approach I can think of after comparing with several other solutions.

This patchset includes:

1/8: Add a new sock zero-copy flag, SOCK_ZEROCOPY;

2/8: Add a new device flag, NETIF_F_ZEROCOPY for lower level device
support zero-copy;

3/8: Add a new struct skb_ubuf_info in skb_share_info for userspace
buffers release callback when lower device DMA has done for that skb;

4/8: Add vhost zero-copy callback in vhost when skb last refcnt is gone;
add vhost_zerocopy_add_used_and_signal to notify guest to release TX skb
buffers.

5/8: Add macvtap zero-copy in lower device when sending packet is
greater than 128 bytes.

6/8: Add Chelsio 10Gb NIC to zero copy feature flag

7/8: Add Intel 10Gb NIC zero copy feature flag

8/8: Add Emulex 10Gb NIC zero copy feature flag

The patchset is built against most recent linux 2.6.git. It has passed
netperf/netserver multiple streams stress test on above NICs.

The single stream test results from 2.6.37 kernel on Chelsio:

64K message size: copy_from_user dropped from 40% to 5%; vhost thread
cpu utilization dropped from 76% to 28%

I am collecting more test results against 2.6.39-rc3 kernel and will
provide the test matrix later.

Thanks
Shirley


