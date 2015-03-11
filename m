From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 0/3 net-next] hyperv: Enable batched notification
Date: Wed, 11 Mar 2015 12:03:55 -0700
Message-ID: <1426100635-9508-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com,
	gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:45808
	"EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbbCKRr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 13:47:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take into consideration the xmit_more flag in skb to decide if we should
notify the host as we place packets in VMBUS.

The VMBUS API that would give us this control is already in Greg's tree, in this
patch-set, that API is exported so it can be used in the netvsc driver.

Also included here is a siganlling related fix in the vmbus driver that is
exposed by the netvsc driver. I would like to thank
Jason Wang <jasowang@redhat.com> for pointing out this issue.

This version of the patch-set, adds an additional patch to fix the
signalling issue.

K. Y. Srinivasan (3):
  Drivers: hv: vmbus: Export the vmbus_sendpacket_pagebuffer_ctl()
  Drivers: hv: vmbus: Fix a bug in the signalling logic with kick_q
  hyperv: Support batched notification

 drivers/hv/channel.c              |   33 +++++++++++++++++++++++++++++++++
 drivers/net/hyperv/hyperv_net.h   |    2 +-
 drivers/net/hyperv/netvsc.c       |   14 +++++++++-----
 drivers/net/hyperv/netvsc_drv.c   |    3 ++-
 drivers/net/hyperv/rndis_filter.c |    2 +-
 5 files changed, 46 insertions(+), 8 deletions(-)

-- 
1.7.4.1
