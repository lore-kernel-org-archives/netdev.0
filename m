From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V3 0/2 net-next] hyperv: Enable batched notification
Date: Tue, 17 Mar 2015 09:02:25 -0700
Message-ID: <1426608145-14139-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Take into consideration the xmit_more flag in skb to decide if we should
notify the host as we place packets in VMBUS.

The VMBUS API that would give us this control is already in Greg's tree, in this
patch-set, that API is exported so it can be used in the netvsc driver. Greg has
acked this export.

In this version of the patch-set, the patch to address the vmbus signalling
fix is not included here; that patch will be taken through Greg's tree.
I have also gotten rid of an unnecessary local variable in start_xmit()
function based on feedback from Jason Wang <jasowang@redhat.com>.

K. Y. Srinivasan (2):
  Drivers: hv: vmbus: Export the vmbus_sendpacket_pagebuffer_ctl()
  hyperv: Support batched notification

 drivers/hv/channel.c              |    1 +
 drivers/net/hyperv/hyperv_net.h   |    2 +-
 drivers/net/hyperv/netvsc.c       |   14 +++++++++-----
 drivers/net/hyperv/netvsc_drv.c   |    2 +-
 drivers/net/hyperv/rndis_filter.c |    2 +-
 5 files changed, 13 insertions(+), 8 deletions(-)

-- 
1.7.4.1
