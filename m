From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next 0/4] hv_netvsc: fix some crashes and hangs on channel/mtu changes
Date: Tue, 31 Oct 2017 14:42:00 +0100
Message-ID: <20171031134204.15287-1-vkuznets@redhat.com>
Cc: linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was found that netvsc driver doesn't survive e.g.

# while true; do ethtool -L eth0 combined 4; ethtool -L eth0 combined 8; done"

test. I was able to identify several issues: hang in guest/host
communication and a couple of crashes. Fix these. While I'm not
convinced I'm fixing everything VMs seem to survive overnight
test. I'll send one more related patch to VMBus core too.

Vitaly Kuznetsov (4):
  hv_netvsc: netvsc_teardown_gpadl() split
  hv_netvsc: protect nvdev->extension with RCU
  hv_netvsc: reset net_device_ctx->nvdev with rcu_assign_pointer()
  hv_netvsc: hide warnings about uninitialized/missing rndis device

 drivers/net/hyperv/hyperv_net.h   |  2 +-
 drivers/net/hyperv/netvsc.c       | 71 ++++++++++++++++++++-------------------
 drivers/net/hyperv/netvsc_drv.c   | 10 +++---
 drivers/net/hyperv/rndis_filter.c | 47 ++++++++++++++++----------
 4 files changed, 74 insertions(+), 56 deletions(-)

-- 
2.13.6
