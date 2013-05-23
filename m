From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC 2/8] macvtap: return -EBADFD when TUNGETIFF fails
Date: Thu, 23 May 2013 11:12:27 +0800
Message-ID: <1369278753-2533-3-git-send-email-jasowang@redhat.com>
References: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tuntap return -EBADFD when TUNGETIFF fails, we should return the same value.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 59e9605..ce1c72a 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -928,7 +928,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		rcu_read_unlock_bh();
 
 		if (!vlan)
-			return -ENOLINK;
+			return -EBADFD;
 
 		ret = 0;
 		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
-- 
1.7.1
