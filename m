From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 7/7] ixgbevf: Tell network stack to stop tx when
	the VF detects PF reset
Date: Sat, 23 Jan 2010 00:47:37 -0800
Message-ID: <20100123084736.9865.42744.stgit@localhost.localdomain>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:53862 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754100Ab0AWIry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 03:47:54 -0500
In-Reply-To: <20100123084457.9865.51853.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

When the VF detects that the PF has reset turn off carrier and stop all
tx queues.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 0a27fa1..623353d 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2381,6 +2381,8 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 					    &link_up, false)) != 0) {
 			adapter->link_up = link_up;
 			adapter->link_speed = link_speed;
+			netif_carrier_off(netdev);
+			netif_tx_stop_all_queues(netdev);
 			schedule_work(&adapter->reset_task);
 			goto pf_has_reset;
 		}

