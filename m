From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 09/11] openvswitch: Enable all GSO features on internal port.
Date: Tue, 29 Oct 2013 17:22:22 -0700
Message-ID: <1383092544-50599-10-git-send-email-jesse@nicira.com>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:39106 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752898Ab3J3AWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:22:44 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so169778pdj.22
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 17:22:44 -0700 (PDT)
In-Reply-To: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

OVS already can handle all types of segmentation offloads that
are supported by the kernel.
Following patch specifically enables UDP and IPV6 segmentation
offloads.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport-internal_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 98d3edb..729c687 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -134,7 +134,7 @@ static void do_setup(struct net_device *netdev)
 	netdev->tx_queue_len = 0;
 
 	netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
-			   NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_TSO;
+			   NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE;
 
 	netdev->vlan_features = netdev->features;
 	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX;
-- 
1.8.3.2
