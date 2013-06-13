From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH 2/2] macvtap: fix uninitialized return value macvtap_ioctl_set_queue()
Date: Thu, 13 Jun 2013 12:21:34 +0800
Message-ID: <1371097294-5626-2-git-send-email-jasowang@redhat.com>
References: <1371097294-5626-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371097294-5626-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return -EINVAL on illegal flag instead of uninitialized value. This fixes the
kbuild test warning.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index acf55ba..9f03ce3 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -969,6 +969,8 @@ static int macvtap_ioctl_set_queue(struct file *file, unsigned int flags)
 		ret = macvtap_enable_queue(vlan->dev, file, q);
 	else if (flags & IFF_DETACH_QUEUE)
 		ret = macvtap_disable_queue(q);
+	else
+		ret = -EINVAL;
 
 	macvtap_put_vlan(vlan);
 	return ret;
-- 
1.7.1
