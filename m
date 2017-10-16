From: Mohammed Gamal <mgamal@redhat.com>
Subject: [PATCH] xen-netfront, xen-netback: Use correct minimum MTU values
Date: Mon, 16 Oct 2017 15:20:32 +0200
Message-ID: <1508160032-21689-1-git-send-email-mgamal@redhat.com>
Cc: linux-kernel@vger.kernel.org, vkuznets@redhat.com,
        otubo@redhat.com, cavery@redhat.com, cheshi@redhat.com,
        Mohammed Gamal <mgamal@redhat.com>
To: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        paul.durrant@citrix.com, wei.liu2@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RFC791 specifies the minimum MTU to be 68, while xen-net{front|back}
drivers use a minimum value of 0.

When set MTU to 0~67 with xen_net{front|back} driver, the network
will become unreachable immediately, the guest can no longer be pinged.

xen_net{front|back} should not allow the user to set this value which causes
network problems.

Reported-by: Chen Shi <cheshi@redhat.com>
Signed-off-by: Mohammed Gamal <mgamal@redhat.com>
---
 drivers/net/xen-netback/interface.c | 2 +-
 drivers/net/xen-netfront.c          | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index ee8ed9da..4491ca5 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -486,7 +486,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 
 	dev->tx_queue_len = XENVIF_QUEUE_LENGTH;
 
-	dev->min_mtu = 0;
+	dev->min_mtu = ETH_MIN_MTU;
 	dev->max_mtu = ETH_MAX_MTU - VLAN_ETH_HLEN;
 
 	/*
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 523387e..8b8689c 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1316,7 +1316,7 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	netdev->features |= netdev->hw_features;
 
 	netdev->ethtool_ops = &xennet_ethtool_ops;
-	netdev->min_mtu = 0;
+	netdev->min_mtu = ETH_MIN_MTU;
 	netdev->max_mtu = XEN_NETIF_MAX_TX_SIZE;
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
-- 
1.8.3.1
