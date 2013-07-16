From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 1/2] macvtap: fix the missing ret value of TUNSETQUEUE
Date: Tue, 16 Jul 2013 13:36:33 +0800
Message-ID: <1373952994-7252-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 441ac0fcaadc76ad09771812382345001dd2b813
(macvtap: Convert to using rtnl lock) forget to return what
macvtap_ioctl_set_queue() returns to its caller. This may break multiqueue API
by always falling through to TUNGETFEATURES.

Cc: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index f2c4a3b..8270b5e 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1103,6 +1103,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		rtnl_lock();
 		ret = macvtap_ioctl_set_queue(file, u);
 		rtnl_unlock();
+		return ret;
 
 	case TUNGETFEATURES:
 		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR |
-- 
1.7.1
