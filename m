From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 26/27] net/hyperv: enable passing of VLAN.CFI bit
Date: Tue, 13 Dec 2016 01:12:42 +0100 (CET)
Message-ID: <3042f5f59a80a79e4edd0b822e5c4d01b1db66e4.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "K. Y. Srinivasan" <kys@microsoft.com> (maintainer:Hyper-V CORE AND
        DRIVERS),
        Haiyang Zhang <haiyangz@microsoft.com> (maintainer:Hyper-V CORE AND
        DRIVERS),
        devel@linuxdriverproject.org (open list:Hyper-V CORE AND DRIVERS)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50220 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932591AbcLMAMp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:45 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/net/hyperv/netvsc_drv.c   | 1 +
 drivers/net/hyperv/rndis_filter.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 6597d79..4e20f4c 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -441,6 +441,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		vlan = (struct ndis_pkt_8021q_info *)((void *)ppi +
 						ppi->ppi_offset);
 		vlan->vlanid = skb->vlan_tci & VLAN_VID_MASK;
+		vlan->cfi = !!(skb->vlan_tci & VLAN_CFI_MASK);
 		vlan->pri = (skb->vlan_tci & VLAN_PRIO_MASK) >>
 				VLAN_PRIO_SHIFT;
 	}
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 7f7b410..9759d73 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -382,6 +382,7 @@ static int rndis_filter_receive_data(struct rndis_device *dev,
 	vlan = rndis_get_ppi(rndis_pkt, IEEE_8021Q_INFO);
 	if (vlan) {
 		vlan_tci = vlan->vlanid |
+			(vlan->cfi ? VLAN_CFI_MASK : 0) |
 			(vlan->pri << VLAN_PRIO_SHIFT);
 	}
 
-- 
2.10.2
