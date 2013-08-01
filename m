From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] macvlan: handle set_promiscuity failures
Date: Thu, 1 Aug 2013 13:50:10 +0300
Message-ID: <1375354185-7257-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's quite unlikely that dev_set_promiscuity will fail,
but worth checking just in case.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/macvlan.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 13937f9..d0f9c2f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -337,8 +337,11 @@ static int macvlan_open(struct net_device *dev)
 	int err;
 
 	if (vlan->port->passthru) {
-		if (!(vlan->flags & MACVLAN_FLAG_NOPROMISC))
-			dev_set_promiscuity(lowerdev, 1);
+		if (!(vlan->flags & MACVLAN_FLAG_NOPROMISC)) {
+			err = dev_set_promiscuity(lowerdev, 1);
+			if (err < 0)
+				goto out;
+		}
 		goto hash_add;
 	}
 
-- 
MST
