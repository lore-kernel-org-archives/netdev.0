From: Samuel Gauthier <samuel.gauthier@6wind.com>
Subject: [PATCH net-next 0/2] ovs: refresh a flow via netlink
Date: Wed, 16 Mar 2016 16:07:50 +0100
Message-ID: <1458140872-22438-1-git-send-email-samuel.gauthier@6wind.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Samuel Gauthier <samuel.gauthier@6wind.com>
To: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38656 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331AbcCPPIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 11:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a netlink api to refresh an existing flow in
openvswitch.

When a packet is sent in the openvswitch kernel datapath and no
flow is found, the packet is sent to the ovs-vswitchd daemon,
which will process the packet, and ask the kernel to create a new
flow. The next packets for this flow will be processed by the
kernel datapath. If a flow is not used for a (configurable)
period of time, ovs-vswitchd removes the flow from the kernel.

As a result, it can be tricky to test the kernel datapath against
packets, as the first packets of each flow will have to go
through the ovs-vswitchd daemon. For instance, to do a zeroloss
performance test, you establish the flows, and then you have to
perform your zeroloss test before the flow is removed by
ovs-vswitchd.

It is possible to configure a flow timeout in ovs-vswitchd (using
other_config:max-idle option), but it changes the behavior for
all the flows, which is not always what you want.

I tested this with a patch for the openvswitch tree of the
ovs-dpctl mod-flow command, which adds a --refresh flag. I will
submit the patch if this patchset is accepted.

Samuel Gauthier (2):
  ovs: split ovs_flow_stats_update into skb and stats
  ovs: support to refresh a flow via netlink

 net/openvswitch/datapath.c |  4 +++-
 net/openvswitch/flow.c     | 23 ++++++++++++++++++-----
 net/openvswitch/flow.h     |  5 +++--
 3 files changed, 24 insertions(+), 8 deletions(-)

-- 
2.2.1.62.g3f15098
