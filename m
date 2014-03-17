From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v4 4/4] brcmfmac: set NET_NAME_USER for P2P ifs
Date: Mon, 17 Mar 2014 20:42:38 +0100
Message-ID: <1395085358-1171-5-git-send-email-dh.herrmann@gmail.com>
References: <1395085358-1171-1-git-send-email-dh.herrmann@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Herrmann <dh.herrmann@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395085358-1171-1-git-send-email-dh.herrmann@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Netdevs created via nl80211 (currently only P2P ifs) have names provided
by user-space. Therefore, set the naming-policy to NET_NAME_USER so it is
correctly shown in sysfs.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
Acked-by: Arend van Spriel <arend@broadcom.com>
Acked-by: Tom Gundersen <teg@jklm.no>
---
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
index fc4f98b..6af4d26 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -2310,6 +2310,7 @@ struct wireless_dev *brcmf_p2p_add_vif(struct wiphy *wiphy, const char *name,
 		goto fail;
 	}
 
+	ifp->ndev->name_assign_type = NET_NAME_USER;
 	strncpy(ifp->ndev->name, name, sizeof(ifp->ndev->name) - 1);
 	err = brcmf_net_attach(ifp, true);
 	if (err) {
-- 
1.9.0
