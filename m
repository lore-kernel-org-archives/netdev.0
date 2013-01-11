From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net] qlge: remove NETIF_F_TSO6 flag
Date: Fri, 11 Jan 2013 16:52:54 +0800
Message-ID: <1357894374-10767-1-git-send-email-amwang@redhat.com>
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56174 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753212Ab3AKIxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 03:53:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is werid that qlge driver supports NETIF_F_TSO6 but
not NETIF_F_IPV6_CSUM. This also causes some kernel warning [1]
when VLAN device setups on a qlge interface.

I think the qlge hardware doesn't support NETIF_F_IPV6_CSUM,
so we have to just remove the NETIF_F_TSO6 flag.

After this patch, the TCP/IPv6 traffic becomes normal again,
no kernel warnings any more.

NOTE: I only tested it on 2.6.32 kernel, even if the upstream
kernel could fix this automatically (it is hard to track NETIF*
flags), removing it is also safe.

1. https://bugzilla.redhat.com/show_bug.cgi?id=891839

Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
Cc: linux-driver@qlogic.com
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index f80cd97..3e73742 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4678,7 +4678,7 @@ static int qlge_probe(struct pci_dev *pdev,
 	qdev = netdev_priv(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN |
+		NETIF_F_TSO | NETIF_F_TSO_ECN |
 		NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
 	ndev->features = ndev->hw_features |
 		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
