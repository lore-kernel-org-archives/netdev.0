From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net v2 0/5] hv_netvsc: fixes for VF removal path
Date: Mon, 15 Aug 2016 17:48:38 +0200
Message-ID: <1471276123-24264-1-git-send-email-vkuznets@redhat.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel crash is reported after VF is removed and detached from netvsc
device. Turns out we have multiple different (but related) issues on the
VF removal path which I'm trying to address with PATCHes 2-5 of this
series. PATCH1 is required to support the change.

Changes since v1:
- Re-arrange patches in the series to not introduce new issues [David Miller]
- Add PATCH5 which fixes a new issue I discovered while testing.
- Add Haiyang' A-b tags to PATCH1-4

With regards to Stephen's suggestion: I believe that switching to using RCU
and eliminating vf_use_cnt/vf_inject is the right thing to do long-term, we
can either put this on top of this series or do it later in net-next.

Vitaly Kuznetsov (5):
  hv_netvsc: don't lose VF information
  hv_netvsc: avoid deadlocks between rtnl lock and vf_use_cnt wait
  hv_netvsc: reset vf_inject on VF removal
  hv_netvsc: protect module refcount by checking
    net_device_ctx->vf_netdev
  hv_netvsc: fix bonding devices check in netvsc_netdev_event()

 drivers/net/hyperv/hyperv_net.h |  24 ++++-----
 drivers/net/hyperv/netvsc.c     |  19 +++-----
 drivers/net/hyperv/netvsc_drv.c | 105 +++++++++++++++++++---------------------
 3 files changed, 66 insertions(+), 82 deletions(-)

-- 
2.7.4
